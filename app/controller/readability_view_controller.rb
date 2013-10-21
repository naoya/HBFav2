# -*- coding: utf-8 -*-
class ReadabilityViewControllerDelegated
  def gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer)
    return true
  end
end

class ReadabilityViewController < HBFav2::UIViewController
  attr_accessor :entry
  include HBFav2::FullScreenable

  def viewDidLoad
    super

    ## 先に viewDidLoad でも設定しておかないと、webview が正しい高さを取れないみたい
    prepare_fullscreen

    self.tracked_view_name  = "Readability"
    self.navigationItem.titleView = TitleLabel.new.tap do |label|
      label.frame = [[0, 0], [view.frame.size.width, 44]]
      if entry[:title].present?
        label.text = entry[:title]
      end
    end

    view << @webview = HBFav2::WebView.new.tap do |v|
      v.frame = CGRectZero
      v.delegate = self
      tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:'toggle_fullscreen:')

      ## Hack: self で受けると ISBackGesture とバッティングするので
      tapGesture.delegate = @delegated = ReadabilityViewControllerDelegated.new
      v.addGestureRecognizer(tapGesture)
    end

    view << @indicator = UIActivityIndicatorView.new.tap do |v|
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end

    app_config = ApplicationConfig.sharedConfig
    rd = Readability::Parser.new
    rd.api_token = app_config.vars['readability']['api_token']
    query = rd.parse_url(entry[:url]) do |response, html|
      @connection = nil

      if response.ok? and @webview
        @webview.loadHTMLString(html, baseURL:entry[:url].nsurl)
      else
        App.alert("変換に失敗しました: " + response.status_code.to_s)
        if @indicator.present?
          @indicator.stopAnimating
        end
      end
    end
    @connection = query.connection
  end

  def viewWillAppear(animated)
    super
    prepare_fullscreen
    @indicator.center = [ view.center.x, view.center.y + 42 ]
    @webview.frame = self.view.frame

    self.navigationItem.leftBarButtonItem = UIBarButtonItem.stop.tap do |btn|
      btn.action = 'on_close'
      btn.target = self
    end

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.titled("Aa").tap do |btn|
      btn.action = 'on_change_font'
      btn.target = self
    end
  end

  def viewWillDisappear(animated)
    super
    cleanup_fullscreen

    self.navigationController.toolbar.translucent = false
    self.navigationController.setToolbarHidden(false, animated:animated)

    if @connection.present?
      @connection.cancel
      App.shared.networkActivityIndicatorVisible = false
    end

    if @webview.loading?
      @webview.stopLoading
    end
  end

  def webViewDidStartLoad (webView)
    App.shared.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad (webView)
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stopAnimating

    ## 画面遷移後に begin_fullscreen が始まってしまい、ステータスバーが消えることがある
    ## まだ応急処置で、完治できていない
    if !self.isBeingDismissed
      begin_fullscreen
    end
  end

  def on_close
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def on_change_font
    font_size = ReadabilityFontSize.sharedFontSize.nextSize
    @webview.stringByEvaluatingJavaScriptFromString(<<"EOF")
document.body.style.fontSize = #{font_size} + '%';
EOF
    SVProgressHUD.showSuccessWithStatus("#{font_size}%")
  end

  def dealloc
    if @webview
      @webview.stopLoading if @webview.loading?
      @webview.delegate = nil
    end
    super
  end
end
