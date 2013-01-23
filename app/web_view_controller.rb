class WebViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    ## Toolbar
    self.navigationController.toolbarHidden = false
    # refresh button
    refreshButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:self, action:'refresh')
    # spacer
    spacer = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
    # XX users button
    usersButton = UIBarButtonItem.alloc.initWithTitle(bookmark.count.to_s, style:UIBarButtonItemStyleBordered, target:self, action:'openBookmarks')
    self.toolbarItems = [refreshButton, spacer, usersButton]

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

  def openBookmarks
    BookmarksViewController.new.tap do |c|
      c.entry = @bookmark
      self.navigationController.pushViewController(c, animated:true)
    end
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

  def refresh
    @webview.reload
  end
end
