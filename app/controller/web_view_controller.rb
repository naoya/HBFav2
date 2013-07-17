# -*- coding: utf-8 -*-
class WebViewController < UIViewController
  attr_accessor :bookmark
  include BrowserControl

  def viewDidLoad
    super

    self.view.backgroundColor = '#fff'.uicolor

    ## Readability Button
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(
      UIButton.custom.tap do |btn|
        btn.frame = [[0, 0], [38, 38]]
        btn.setImage(UIImage.imageNamed('readability'), forState: :normal.uicontrolstate)
        btn.on(:touch) do
          ReadabilityViewController.new.tap do |c|
            c.bookmark = @bookmark
            self.presentViewController(
              UINavigationController.alloc.initWithRootViewController(c),
              animated:true,
              completion:nil
            )
          end
        end
      end
    )

    ## Toolbar
    self.initialize_toolbar

    ## Title
    self.navigationItem.titleView = UILabel.new.tap do |label|
      label.frame = [[0, 0], [400, 44]]
      label.font = UIFont.boldSystemFontOfSize(14.0)
      label.backgroundColor = UIColor.clearColor
      label.shadowColor = UIColor.colorWithWhite(0.0, alpha: 0.5)
      label.textAlignment = UITextAlignmentCenter
      label.textColor = UIColor.whiteColor
      label.text = @bookmark.title
    end

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
end
