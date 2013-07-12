# -*- coding: utf-8 -*-
class ReadabilityViewController < UIViewController
  attr_accessor :url

  def viewDidLoad
    super

    self.navigationController.navigationBar.translucent = true
    self.navigationController.setToolbarHidden(true, animated:false)

    @webview = UIWebView.new.tap do |v|
      v.delegate =self
      v.frame = self.view.bounds
      tapGesture = UITapGestureRecognizer.alloc.initWithTarget(self, action:'toggle_navbar')
      tapGesture.delegate = self
      v.addGestureRecognizer(tapGesture)
    end
    view << @webview

    @indicator = UIActivityIndicatorView.new.tap do |v|
      v.center = [view.frame.size.width / 2, view.frame.size.height / 2 - 42]
      v.style = UIActivityIndicatorViewStyleGray
      v.startAnimating
    end
    view << @indicator

    ## Readability
    token = 'c523147005e6a6af0ec079ebb7035510b3409ee5'
    api = "https://www.readability.com/api/content/v1/parser?url=#{url}&token=#{token}"

    # debug
    puts api

    BW::HTTP.get(api) do |response|
      if response.ok?
        data = BW::JSON.parse(response.body.to_str)
        self.navigationItem.title = data['title']

        html =<<"EOF"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>#{data['title']}</title>
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
<style type="text/css">
body {
  background-color: #fff;
  width: 90%;
  margin-left: auto;
  margin-right: auto;
  padding-top: 20px;
  padding-bottom: 20px;
}

a {
  text-decoration: none;
}

img {
  max-width: 100%;
}

h1 {
  font-size: 120%;
  font-family: sans-serif;
  border-bottom: 1px solid #ccc;
  padding-bottom: 10px;
  margin-bottom: 0;
}

h2, h3, h4 {
  font-family: sans-serif;
}

h2 {
  font-size: 110%;
}

h3, h4 {
  font-size: 100%;
}

p.domain {
  color: #666;
  font-family: serif;;
  font-size: 80%;
  margin-top: 10px;
  padding-top: 0;
}

div.content {
  margin-top: 3em;
  font-size: 95%;
  line-height: 180%;
}
</style>
</head>
<body>
<h1>#{data['title']}</h1>
<p class="domain">#{data['domain']}</p>
<div class="content">
#{data['content']}
</div>
</body>
</html>
EOF
        self.hide_navbar
        @webview.loadHTMLString(html, baseURL:self.url.nsurl)
      else
        # SVProgressHUD.showErrorWithStatus("失敗: " + response.status_code.to_s)
        App.alert("変換に失敗しました: " + response.status_code.to_s)
      end
      @indicator.stopAnimating
    end
  end

  def viewWillAppear(animated)
    super
    @webview.frame = self.view.bounds
  end

  def viewWillDisappear(animated)
    self.navigationController.navigationBar.translucent = false
  end

  def gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer)
    true
  end

  def toggle_navbar
    self.navigationController.isNavigationBarHidden ? self.show_navbar : self.hide_navbar
  end

  def hide_navbar
    self.navigationController.setNavigationBarHidden(true, animated:true)
  end

  def show_navbar
    self.navigationController.setNavigationBarHidden(false, animated:true)
  end
end
