# -*- coding: utf-8 -*-
class WebViewController < HBFav2::UIViewController
  attr_accessor :bookmark, :on_modal

  def viewDidLoad
    super

    @bookmark_requested = {
      @bookmark.link => {
        :http_requested => false,
        :bookmark       => @bookmark
      }
    }

    @link_clicked = nil

    @document_title = nil
    self.tracked_view_name = "WebView"
    self.view.backgroundColor = '#fff'.uicolor
    self.initialize_toolbar

    self.navigationItem.titleView = TitleLabel.new.tap do |label|
      label.frame = self.navigationController.navigationBar.bounds
      label.text = @bookmark.title
    end

    self.view << @webview = HBFav2::WebViewBridge.factory(self.view.bounds).tap do |v|
      v.backgroundColor = '#fff'.uicolor
      v.scalesPageToFit = true
      v.delegate = self
    end

    self.view << @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end

    self.navigationItem.rightBarButtonItem = ReadabilityBarButtonItem.alloc.initWithTarget(self, action:'open_readability')

    if self.on_modal == true

      UIBarButtonItem.stop.tap do |btn|
        btn.action = 'on_close'
        btn.target = self
      end
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemStop,
        target:self,
        action:'on_close'
      )
    end

    @webview.becomeFirstResponder
    @webview.loadRequest(NSURLRequest.requestWithURL(@bookmark.link.nsurl))
  end

  def viewWillAppear(animated)
    super
    self.navigationController.toolbar.translucent = false
    self.navigationController.setToolbarHidden(false, animated:animated)
  end

  def viewDidAppear(animated)
    super
    @webview.frame = view.frame
    @indicator.center = [ view.center.x, view.center.y + 42 ]
  end

  def viewWillDisappear(animated)
    super

    if (@view_pushed)
      ## Flag indicates that view disappeared because we pushed another
      ## controller onto the navigation controller, we acknowledge it here
      @view_pushed = false
    else
      ## Here, you know that back button was pressed
      if @webview and @webview.loading?
        @webview.stopLoading
      end
    end

    if @connection.present?
      @connection.cancel
    end
  end

  def update_bookmark
    url = @webview.URL.absoluteString
    @bookmark_requested[url] ||= {}

    if @bookmark_requested[url][:http_requested]
      ## 戻るボタンのときは前のブックマークインスタンスに更新
      update_bookmark_info(@bookmark_requested[url][:bookmark])
      return
    end
    @bookmark_requested[url][:http_requested] = true

    query = BW::HTTP.get("http://b.hatena.ne.jp/entry/jsonlite/", {payload: {url: url}}) do |response|
      if response.ok?
        ## まだ画面遷移が一度も発生してない場合はオブジェクトの更新は必要ない (リダイレクト対策)
        ## ただし、その場合でもブックマークコメントの先読みのためにリクエストはしておく
        if @bookmark.count.nil? or @link_clicked
          autorelease_pool {
            data = BW::JSON.parse(response.body.to_str) || {}
            @bookmark_requested[url][:bookmark] = bookmark = Bookmark.new(
              {
                :eid   => data['eid'] || nil,
                :title => data['title'] || @webview.title,
                :link  => url,
                :count => data['count'] || 0,
              }
            )
            update_bookmark_info(bookmark)
          }
        end
      else
        # TODO:
      end
      @connection = nil
    end
    @connection = query.connection
  end

  def update_bookmark_info(bookmark)
    if bookmark.present?
      @bookmark = bookmark
      self.navigationItem.titleView.text = bookmark.title if self.navigationItem.present?
      update_bookmark_count(bookmark)
    end
  end

  def update_bookmark_count(bookmark)
    cnt = bookmark.count.nil? ? " - users" : bookmark.count.to_s
    @bookmarkButton.setTitle(cnt, forState:UIControlStateNormal)
    @bookmarkButton.enabled = bookmark.count.to_i > 0
  end

  #
  # Toolbar
  #
  def initialize_toolbar
    self.navigationController.setToolbarHidden(false, animated:false)
    self.navigationController.toolbar.translucent = false
    self.toolbarItems = [
      @backButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(101, target:self, action:'on_back').tap { |b| b.enabled = false },
      UIBarButtonItem.flexiblespace,
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:self, action:'on_refresh'),
      UIBarButtonItem.flexiblespace,
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCompose, target:self, action: 'on_bookmark'),
      UIBarButtonItem.flexiblespace,
      # BookmarkBarButtonItem.alloc.initWithTarget(self, action:'on_bookmark'),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'on_action'),
      UIBarButtonItem.flexiblespace,
      @bookmarkButton = UIBarButtonItem.titled('', :bordered).tap do |btn|
        btn.target = self
        btn.action = 'open_bookmark'
      end,
    ]
    self.update_bookmark_count(@bookmark)
  end

  def on_back
    @webview.goBack
  end

  def on_forward
    @webview.goForward
  end

  def on_refresh
    @webview.reload
  end

  def present_modal (controller)
    @view_pushed = true
    self.presentViewController(controller, animated:true, completion:nil)
  end

  def open_readability
    readability = ReadabilityViewController.new.tap do |c|
      c.entry = {:title => @bookmark.title, :url => @bookmark.link}
    end

    controller = HBFav2NavigationController.alloc.initWithRootViewController(readability)
    controller.rounded_corners = false

    ## 本当は pushViewController にしたいが JASidePanels との相性でフルスクリーンがムズイので modal
    present_modal(controller)
  end

  def open_bookmark
    controller = BookmarksViewController.new.tap do |c|
      c.entry = @bookmark
    end
    present_modal(HBFav2NavigationController.alloc.initWithRootViewController(controller))
  end

  def on_bookmark
    open_hatena_bookmark_view
  end

  def open_hatena_bookmark_view
    @controller = HTBHatenaBookmarkViewController.alloc.init
    @controller.URL = @bookmark.link.nsurl
    self.presentViewController(@controller, animated:true, completion:nil)
  end

  def on_action
    controller = URLActivityViewController.alloc.initWithDefaultActivities([@bookmark.title, @bookmark.link.nsurl])
    if controller.popoverPresentationController
      controller.popoverPresentationController.sourceView = self.view
      frame = self.view.frame
      new_frame = CGRectMake(frame.size.width/5, UIScreen.mainScreen.bounds.size.height - 40, frame.size.width, frame.size.height)
      controller.popoverPresentationController.sourceRect = new_frame
    end

    present_modal(controller)
  end

  def on_close
    self.dismissModalViewControllerAnimated(true, completion:nil)
  end

  #
  # UIWebView delegate
  #
  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad (webView)
    update_bookmark

    if @backButton.present?
      @backButton.enabled = webView.canGoBack
    end
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating
  end

  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    url = request.URL
    if url.absoluteString =~ %r{https?://itunes.apple.com}
      UIApplication.sharedApplication.openURL(url)
    end

    if (navigationType == UIWebViewNavigationTypeLinkClicked)
      @link_clicked = true
    end
    true
  end

  #
  # WKWebView delegate
  #
  def webView(webView, didStartProvisionalNavigation:navigation)
    self.webViewDidStartLoad(webView)
  end

  def webView(webView, didFinishNavigation:navigation)
    self.webViewDidFinishLoad(webView)
  end

  def webView(webView, decidePolicyForNavigationAction:navigationAction, decisionHandler:decisionHandler)
    url = navigationAction.request.URL
    if url.absoluteString =~ %r{https?://itunes.apple.com}
      UIApplication.sharedApplication.openURL(url)
      decisionHandler.call(WKNavigationActionPolicyCancel)
      return
    end

    if navigationAction.navigationType == WKNavigationTypeLinkActivated
      @link_clicked = true
    end
    decisionHandler.call(WKNavigationActionPolicyAllow)
  end

  def webView(webView, createWebViewWithConfiguration:configuration, forNavigationAction:navigationAction, windowFeatures:windowFeatures)
    url = navigationAction.request.URL.absoluteString
    controller = WebViewController.new.tap do |c|
      c.bookmark = Bookmark.new({ :link => url })
    end
    self.navigationController.pushViewController(controller, animated:true)
    return nil
  end

  def didReceiveMemoryWarning
    super
    NSURLCache.sharedURLCache.removeAllCachedResponses
    NSLog("Removed shared cache on NSURLCache")
  end

  def dealloc
    if @webview
      @webview.stopLoading if @webview.loading?
      @webview.delegate = nil
    end
    super
  end
end
