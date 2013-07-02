class WebViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    ## Toolbar
    self.navigationController.toolbarHidden = false
    spacer = UIBarButtonItem.flexiblespace

    self.toolbarItems = [
      @backButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(101, target:self, action:'on_back').tap { |b| b.enabled = false },
      spacer,
      @forwardButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(102, target:self, action:'on_forward').tap { |b| b.enabled = false },
      spacer,
      refreshButton = UIBarButtonItem.refresh { @webview.reload },
      spacer,
      UIBarButtonItem.action {}, # TODO
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
      v.frame = self.view.bounds
      v.scalesPageToFit = true
      v.loadRequest(NSURLRequest.requestWithURL(@bookmark.link.nsurl))
      v.delegate = self
      view << v
    end

    ## Activity Indicator
    @indicator = UIActivityIndicatorView.new.tap do |v|
      v.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 42]
      v.style = UIActivityIndicatorViewStyleGray
      view << v
    end
  end

  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    @backButton.enabled    = webView.canGoBack
    @forwardButton.enabled = webView.canGoForward
    return true
  end

  def viewWillDisappear(animated)
    if @webview.loading?
      @webview.stopLoading
    end
    super
  end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
    @indicator.startAnimating
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

  def dealloc
    if @webview.loading?
      @webview.stopLoading
    end
    @webview.delegate = nil
  end
end
