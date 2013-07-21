# -*- coding: utf-8 -*-
class ReadabilityViewController < UIViewController
  attr_accessor :entry

  def viewDidLoad
    super

    ## 先に viewDidLoad でも設定しておかないと、webview が正しい高さを取れないみたい
    prepare_fullscreen

    self.navigationItem.titleView = TitleLabel.new.tap do |label|
      label.frame = [[0, 0], [view.frame.size.width, 44]]
      if entry[:title].present?
        label.text = entry[:title]
      end
    end

    self.view.backgroundColor = UIColor.redColor
    self.navigationItem.leftBarButtonItem  =
      UIBarButtonItem.stop { self.dismissViewControllerAnimated(true, completion:nil) }

    view << @webview = UIWebView.new.tap do |v|
      v.frame = CGRectZero
      v.delegate = self
      tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:'toggle_fullscreen')
      tapGesture.delegate = self
      v.addGestureRecognizer(tapGesture)
    end

    view << @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end

    rd = Readability::Parser.new
    rd.api_token = 'c523147005e6a6af0ec079ebb7035510b3409ee5'
    rd.parse_url(entry[:url]) do |response, html|
      if response.ok?
        @webview.loadHTMLString(html, baseURL:entry[:url].nsurl)
      else
        ## TODO: notify to user
        # App.alert("変換に失敗しました: " + response.status_code.to_s)
        @indicator.stopAnimating
      end
    end
  end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad (webView)
    App.shared.networkActivityIndicatorVisible = false
    begin_fullscreen
    @indicator.stopAnimating
  end

  def prepare_fullscreen
    @fullscreen = false
    self.navigationController.setToolbarHidden(true, animated:false)
    self.navigationController.setNavigationBarHidden(false, animated:false)
    self.navigationController.navigationBar.translucent = true
    self.navigationController.toolbar.translucent = true
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackTranslucent
    self.wantsFullScreenLayout = true
  end

  def cleanup_fullscreen
    @fullscreen = false
    self.navigationController.setNavigationBarHidden(false, animated:false)
    self.navigationController.navigationBar.translucent = false
    self.navigationController.toolbar.translucent = false
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque
    self.wantsFullScreenLayout = false
  end

  def viewWillAppear(animated)
    super
    prepare_fullscreen
    @indicator.center = [view.frame.size.width / 2, view.frame.size.height / 2]
    @webview.frame = self.view.frame
    @webview.layoutSubviews
  end

  def viewWillDisappear(animated)
    super
    cleanup_fullscreen
    self.navigationController.setToolbarHidden(false, animated:animated)
  end

  def toggle_fullscreen
    @fullscreen = !@fullscreen
    @fullscreen ? begin_fullscreen : end_fullscreen
  end

  def begin_fullscreen
    @fullscreen = true
    UIView.beginAnimations(nil, context:nil)
    UIView.setAnimationDuration(0.3)
    UIApplication.sharedApplication.setStatusBarHidden(true, animated:true)
    if navigationController.navigationBar.present?
      navigationController.navigationBar.alpha = 0.0
    end
    UIView.commitAnimations
  end

  def end_fullscreen
    @fullscreen = false
    UIView.beginAnimations(nil, context:nil)
    UIView.setAnimationDuration(0.3)
    UIApplication.sharedApplication.setStatusBarHidden(false, animated:true)
    if navigationController.navigationBar.present?
      navigationController.navigationBar.alpha = 1.0
    end
    UIView.commitAnimations
  end

  def dealloc
    if @webview.loading?
      @webview.stopLoading
    end
    @webview.delegate = nil
    super
  end

  def gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer)
    true
  end
end
