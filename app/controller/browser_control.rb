## some properties required: @webview, @indicator, @bookmark
## initilize_toolbar must be called at viewDidLoad
module BrowserControl
  include SugarCube::Modal
  # def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
  #   @backButton.enabled    = webView.canGoBack
  #   @forwardButton.enabled = webView.canGoForward
  #   return true
  # end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad (webView)
    @backButton.enabled    = webView.canGoBack
    @forwardButton.enabled = webView.canGoForward
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating
  end

  def on_back
    @webview.goBack
  end

  def on_forward
    @webview.goForward
  end

  def dealloc
    if @webview.loading?
      @webview.stopLoading
    end
    @webview.delegate = nil

    super
  end

  def initialize_toolbar
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
      UIBarButtonItem.titled(@bookmark.count.to_s, :bordered) do
        BookmarksViewController.new.tap do |c|
          c.entry = @bookmark
          present_modal(UINavigationController.alloc.initWithRootViewController(c))
        end
      end
    ]
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
    present_modal(@activity)
  end
end
