class ReadabilityViewController < UIViewController
  attr_accessor :data

  def viewDidLoad
    super

    self.navigationItem.title = data['title']
    self.navigationController.setToolbarHidden(true, animated:false)

    @webview = UIWebView.new.tap do |v|
      # v.scalesPageToFit = true
      v.delegate = self
      v.frame = self.view.bounds
      # resize = [ :width, :height ]
      content = data['content']
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
#{content}
  </body>
</html>
EOF
      v.loadHTMLString(html, baseURL:nil)
    end

    view << @webview
  end

  def viewWillAppear(animated)
    super
    @webview.frame = self.view.bounds
  end
end
