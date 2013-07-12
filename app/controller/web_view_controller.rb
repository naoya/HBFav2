# -*- coding: utf-8 -*-
class WebViewController < UIViewController
  # include HBFav::URI::Escape
  attr_accessor :bookmark

  def viewDidLoad
    super

    ## Readability Button
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(
      UIButton.custom.tap do |btn|
        btn.frame = [[0, 0], [38, 38]]
        btn.setImage(UIImage.imageNamed('readability'), forState: :normal.uicontrolstate)
        btn.on(:touch) do
          self.navigationController.pushViewController(
            ReadabilityViewController.new.tap { |c| c.url = @bookmark.link },
            animated:true
          )
        end
      end
    )

    ## Toolbar
    self.navigationController.setToolbarHidden(false, animated:false)
    spacer = UIBarButtonItem.flexiblespace

    self.toolbarItems = [
      @backButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(101, target:self, action:'on_back').tap { |b| b.enabled = false },
      spacer,
      @forwardButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(102, target:self, action:'on_forward').tap { |b| b.enabled = false },
      spacer,
      refreshButton = UIBarButtonItem.refresh { @webview.reload },
      spacer,
      UIBarButtonItem.action { on_action },
      spacer,
      UIBarButtonItem.titled(bookmark.count.to_s, :bordered) do
        BookmarksViewController.new.tap do |c|
          c.entry = @bookmark
          self.navigationController.pushViewController(c, animated:true)
        end
      end
    ]

    ## Title
    self.navigationItem.title = @bookmark.title

    ## WebView
    @webview = UIWebView.new.tap do |v|
      v.scalesPageToFit = true
      v.loadRequest(NSURLRequest.requestWithURL(@bookmark.link.nsurl))
      v.delegate = self
      view << v
    end

    ## Activity Indicator
    @indicator = UIActivityIndicatorView.new.tap do |v|
      v.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 42]
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
      view << v
    end
  end

  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    @backButton.enabled    = webView.canGoBack
    @forwardButton.enabled = webView.canGoForward
    return true
  end

  # http://stackoverflow.com/questions/4492683/why-do-i-have-to-subtract-for-height-of-uinavigationbar-twice-to-get-uiwebview-t
  def viewWillAppear(animated)
    super
    self.navigationController.setToolbarHidden(false, animated:false)
    @webview.frame = self.view.bounds
  end

  def viewWillDisappear(animated)
    self.navigationController.setToolbarHidden(true, animated:animated)
    ## Readability を先に開くとローディングが止まっちゃうので
    # if @webview.loading?
    #  @webview.stopLoading
    # end
  end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
    # @indicator.startAnimating
  end

  def webViewDidFinishLoad (webView)
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating
  end

  def webView(webView, didFailLoadWithError:error)
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating
  end

  def on_back
    @webview.goBack
  end

  def on_forward
    @webview.goForward
  end

  def on_action
    @safari = TUSafariActivity.new
    @pocket = PocketActivity.new
    @hatena = HatenaBookmarkActivity.new
#    @readability = ReadabilityActivity.new.tap do |activity|
#      activity.navigationController = self.navigationController
#    end
    @add_bookmark = AddBookmarkActivity.new.tap do |activity|
      user = ApplicationUser.sharedUser
      activity.hatena_id = user.hatena_id
      activity.password  = user.password
    end

    @activity = UIActivityViewController.alloc.initWithActivityItems(
      [@bookmark.title, @bookmark.link.nsurl],
      applicationActivities:[
        @add_bookmark,
        @pocket,
        @safari,
#        @readability,
        @hatena,
      ]
    )
    @activity.excludedActivityTypes = [UIActivityTypeMessage, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard]
    presentModalViewController(@activity, animated:true)
  end

  def dealloc
    if @webview.loading?
      @webview.stopLoading
    end
    @webview.delegate = nil
  end
end
