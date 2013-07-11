# -*- coding: utf-8 -*-
class ReadabilityViewController < UIViewController
  attr_accessor :url

  def viewDidLoad
    super

    # self.navigationItem.title = data['title']
    self.navigationController.setToolbarHidden(true, animated:false)

    @webview = UIWebView.new.tap do |v|
      v.delegate =self
      v.frame = self.view.bounds
    end
    view << @webview

    ## Readability
    token = 'c523147005e6a6af0ec079ebb7035510b3409ee5'
    api = "https://www.readability.com/api/content/v1/parser?url=#{url}&token=#{token}"

    ## debug
    puts api

    SVProgressHUD.showWithStatus("変換中...")

    BW::HTTP.get(api) do |response|
      if response.ok?
        SVProgressHUD.dismiss
        data = BW::JSON.parse(response.body.to_str)
        self.navigationItem.title = data['title']

        html =<<"EOF"
<html>
  <head>
  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
  <style type="text/css">
    img {
      max-width: 100%;
    }
  </style>
  </head>
  <body>
    <h1>#{data['title']}</h1>
    #{data['content']}
  </body>
</html>
EOF
        @webview.loadHTMLString(html, baseURL:nil)
      else
        SVProgressHUD.showErrorWithStatus("失敗: " + response.status_code.to_s)
      end
    end
  end

  def viewWillAppear(animated)
    super
    @webview.frame = self.view.bounds
  end
end
