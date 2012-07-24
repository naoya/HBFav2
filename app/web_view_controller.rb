class WebViewController < UIViewController
  attr_accessor :bookmark

  def init
    return self
  end

  def viewDidLoad
    super

    ## Toolbar
    self.navigationController.toolbarHidden = false
    button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:self, action:'refresh')
    self.toolbarItems = [button]

    ## Title
    self.navigationItem.title = @bookmark.title

    ## WebView
    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.scalesPageToFit = true
      # v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@bookmark[:link])))
      v.loadRequest(NSURLRequest.requestWithURL(@bookmark.link.nsurl))
      v.delegate = self
      # self.view.addSubview(v)
      view << v
    end

    ## Activity Indicator
    @indicator = UIActivityIndicatorView.new.tap do |v|
      # v.frame = [[view.bounds.size.width / 2, view.bounds.size.height / 2], [20, 20]]
      v.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 42]
      v.style = UIActivityIndicatorViewStyleGray
      # self.view.addSubview(v)
      view << v
    end
  end

  def webViewDidStartLoad (webView)
    @indicator.startAnimating
  end

  def webViewDidFinishLoad (webView)
    @indicator.stopAnimating
  end

  def webView(webView, didFailLoadWithError:error)
    @indicator.stopAnimating
  end

  def refresh
    @webview.reload
  end
end
