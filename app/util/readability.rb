# -*- coding: utf-8 -*-
module Readability
  class Parser
    attr_accessor :api_token
    API = "https://www.readability.com/api/content/v1/parser"

    def parse_url(url, &cb)
      query = BW::HTTP.get(API, {payload: {url: url, token: api_token}}) do |response|
        if response.ok?
          data = BW::JSON.parse(response.body.to_str)
          cb.call(response, html(data)) if cb
        else
          cb.call(response, nil) if cb
        end
      end
      query
    end

    def html(data)
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
  word-wrap: break-word;
  font-family: "Hiragino Mincho ProN", serif;
  color: #000;
}

a {
  text-decoration: none;
  color: #000;
  border-bottom: 1px dotted #ccc;
  padding-bottom: 2px;
}

img, video, iframe {
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
  font-size: 100%;
  line-height: 180%;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}

blockquote {
  margin-left: 20px;
  margin-right: 20px;
  color: #333;
  font-style: italic;
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
    end
  end
end
