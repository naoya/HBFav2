# -*- coding: utf-8 -*-
class ReadabilityViewController < UIViewController
  attr_accessor :bookmark

  def viewDidLoad
    super

    # self.initialize_toolbar
    self.view.backgroundColor = '#fff'.uicolor

    self.wantsFullScreenLayout = true
    self.navigationController.navigationBar.translucent = true
    # self.navigationController.toolbar.translucent = true
    self.navigationItem.title = @bookmark.title
    self.navigationItem.leftBarButtonItem  =
      UIBarButtonItem.stop { self.dismissViewControllerAnimated(true, completion:nil) }

    @webview = UIWebView.new.tap do |v|
      v.delegate =self
      v.frame = self.view.bounds
      tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:'toggle_bars')
      tapGesture.delegate = self
      v.addGestureRecognizer(tapGesture)
    end
    view << @webview

    @indicator = UIActivityIndicatorView.new.tap do |v|
      v.center = [view.frame.size.width / 2, view.frame.size.height / 2]
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end
    view << @indicator

    rd = Readability::Parser.new
    rd.api_token = 'c523147005e6a6af0ec079ebb7035510b3409ee5'
    rd.parse_url(@bookmark.link) do |response, html|
      if response.ok?
        @webview.loadHTMLString(html, baseURL:self.bookmark.link.nsurl)
        self.hide_bars
      else
        App.alert("変換に失敗しました: " + response.status_code.to_s)
      end
      @indicator.stopAnimating
    end
  end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad (webView)
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating
  end

  def viewWillAppear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated:false)
    self.navigationController.navigationBar.translucent = true
    self.navigationController.toolbar.translucent = true
    @webview.frame = self.view.bounds
  end

  def viewWillDisappear(animated)
    super
    self.navigationController.navigationBar.translucent = false
    # self.navigationController.toolbar.translucent = false
    self.navigationController.setToolbarHidden(false, animated:animated)
    self.show_bars
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

  def toggle_bars
    self.toggle_statbar
    self.toggle_navbar
    self.toggle_toolbar
  end

  def hide_bars
    self.hide_statbar
    self.hide_navbar
    self.hide_toolbar
  end

  def show_bars
    self.show_statbar
    self.show_navbar
    self.show_toolbar
  end

  def toggle_statbar
    UIApplication.sharedApplication.isStatusBarHidden ? self.show_statbar : self.hide_statbar
  end

  def hide_statbar
    UIApplication.sharedApplication.setStatusBarHidden(true, withAnimation:true)
  end

  def show_statbar
    UIApplication.sharedApplication.setStatusBarHidden(false, withAnimation:true)
  end

  def toggle_navbar
    #    self.navigationController.isNavigationBarHidden ? self.show_navbar : self.hide_navbar
    @navbar_hidden ? self.show_navbar : self.hide_navbar
  end

  def hide_navbar
    if self.navigationController.present? # タイミングによっては nil のときがある
      self.navigationController.navigationBar.fade_out(duration: 0.5)
      @navbar_hidden = true
    end
  end

  def show_navbar
    if self.navigationController.present?
      self.navigationController.navigationBar.fade_in(duration: 0.5)
      @navbar_hidden = false
    end
#    self.navigationController.setNavigationBarHidden(false, animated:true)
  end

  def toggle_toolbar
    @toolbar_hidden ? self.show_toolbar : self.hide_toolbar
  end

  def hide_toolbar
    if self.navigationController.present?
      self.navigationController.toolbar.fade_out(duration: 0.5)
      @toolbar_hidden = true
    end
  end

  def show_toolbar
    if self.navigationController.present?
      self.navigationController.toolbar.fade_in(duration: 0.5)
      @toolbar_hidden = false
    end
  end
end
