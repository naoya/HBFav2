# -*- coding: utf-8 -*-
class WebViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    @bookmark_requested = {}
    @link_clicked = nil

    @document_title = nil
    self.backGestureEnabled = true
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")
    self.view.backgroundColor = '#fff'.uicolor
    self.initialize_toolbar

    self.navigationItem.titleView = TitleLabel.new.tap do |label|
      label.frame = self.navigationController.navigationBar.bounds
      label.text = @bookmark.title
    end

    ## WebView
    @proxy = NJKWebViewProgress.alloc.init
    self.view << @webview = HBFav2::WebView.new.tap do |v|
      v.scalesPageToFit = true
      v.backgroundColor = '#fff'.uicolor
      v.loadRequest(NSURLRequest.requestWithURL(@bookmark.link.nsurl))
      v.delegate = @proxy
    end

    @proxy.webViewProxyDelegate = self
    @proxy.progressDelegate = self

    ## Activity Indicator
    self.view << @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end

    self.navigationItem.rightBarButtonItem = ReadabilityBarButtonItem.alloc.initWithTarget(self, action:'open_readability')
  end

  def viewWillAppear(animated)
    super

    ## 応急処置
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:false)
    self.wantsFullScreenLayout = false

    self.navigationController.toolbar.translucent = false
    self.navigationController.setToolbarHidden(false, animated:animated)

    ## FIXME: Readability から戻ってくると画面の大きさがおかしくなる
    @webview.frame = view.frame
    @indicator.center = [@webview.bounds.size.width / 2, @webview.bounds.size.height / 2]
  end

  def viewWillDisappear(animated)
    super

    if (@view_pushed)
      ## Flag indicates that view disappeared because we pushed another
      ## controller onto the navigation controller, we acknowledge it here
      @view_pushed = false
    else
      ## Here, you know that back button was pressed
      if @webview.loading?
        @webview.stopLoading
      end
    end

    if @connection.present?
      @connection.cancel
    end
  end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad (webView)
    update_bookmark

    if @backButton.present?
      @backButton.enabled    = webView.canGoBack
    end
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating
  end

  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
      @link_clicked = true
    end
    true
  end

  def update_bookmark
    url = @webview.request.URL.absoluteString
    @bookmark_requested[url] ||= {}

    if @bookmark_requested[url][:http_requested]
      ## 戻るボタンのときは前のブックマークインスタンスに更新
      update_bookmark_info(@bookmark_requested[url][:bookmark])
      return
    end
    @bookmark_requested[url][:http_requested] = true

    query = BW::HTTP.get("http://b.hatena.ne.jp/entry/jsonlite/", {payload: {url: url}}) do |response|
      NSLog("DEBUG: done HTTP request")

      if response.ok?
        ## まだ画面遷移が一度も発生してない場合はオブジェクトの更新は必要ない (リダイレクト対策)
        ## ただし、その場合でもブックマークコメントの先読みのためにリクエストはしておく
        if @bookmark.count.nil? or @link_clicked
          autorelease_pool {
            data = BW::JSON.parse(response.body.to_str) || {}
            @bookmark_requested[url][:bookmark] = @bookmark = Bookmark.new(
              {
                :eid   => data['eid'] || nil,
                :title => data['title'] || @webview.stringByEvaluatingJavaScriptFromString("document.title"),
                :link  => url,
                :count => data['count'] || 0,
              }
            )
            update_bookmark_info(@bookmark)
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
      self.navigationItem.titleView.text = bookmark.title if self.navigationItem.present?
      update_bookmark_count(bookmark)
    end
  end

  def update_bookmark_count(bookmark)
    cnt = bookmark.count.nil? ? " - users" : bookmark.count.to_s
    @bookmarkButton.setTitle(cnt, forState:UIControlStateNormal)
    @bookmarkButton.enabled = bookmark.count.to_i > 0
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

  def present_modal (controller)
    @view_pushed = true
    self.presentViewController(controller, animated:true, completion:nil)
  end

  def open_readability
    controller = ReadabilityViewController.new.tap do |c|
      c.entry = {:title => @bookmark.title, :url => @bookmark.link}
    end

    ## 本当は pushViewController にしたいが JASidePanels との相性でフルスクリーンがムズイので modal
    present_modal(UINavigationController.alloc.initWithRootViewController(controller))
    # self.navigationController << controller
  end

  def open_bookmark
    controller = BookmarksViewController.new.tap do |c|
      c.entry = @bookmark
    end
    present_modal(HBFav2NavigationController.alloc.initWithRootViewController(controller))
  end

  def on_bookmark
    if HTBHatenaBookmarkManager.sharedManager.authorized
      open_hatena_bookmark_view
    else
      ## TODO
      # HTBHatenaBookmarkManager.sharedManager.authorizeWithSuccess(
      #   lambda { open_bookmark_view },
      #   failure: lambda {|error| NSLog(error.localizedDescription) }
      # )
    end
  end

  def open_hatena_bookmark_view
    controller = HTBHatenaBookmarkViewController.alloc.init
    controller.URL = @bookmark.link.nsurl
    present_modal(controller)
  end

  def on_action
    present_modal(
      URLActivityViewController.alloc.initWithDefaultActivities([@bookmark.title, @bookmark.link.nsurl])
    )
  end

  def webViewProgress(webViewProgress, updateProgress:progress)
    ## progress (demo)
    if (progress == 0)
      unless @progress.nil?
        @progress.removeFromSuperview
        @progress = nil
      end

      self.view <<@progress = ChromeProgressBar.new.tap do |v|
        v.frame = [self.view.bounds.origin, [self.view.bounds.size.width, 5 ] ]
      end
      @progress.progress = 0
      # UIView.animateWithDuration(0.27, animations:lambda {  @progress.alpha = 1.0 })
    end

    if (progress == 1.0)
      UIView.animateWithDuration(0.27, delay:progress - @progress.progress, options:0, animations:lambda { @progress.alpha = 0.0 }, completion:nil)
    end
    @progress.setProgress(progress, animated:false)
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    if @webview.loading?
      @webview.stopLoading
    end
    @webview.delegate = nil
    super
  end
end
