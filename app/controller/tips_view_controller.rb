# -*- coding: utf-8 -*-
class TipsViewController < UIViewController
  def viewDidLoad
    super

    self.title = "TIPS"
    self.backGestureEnabled = true

    view << @webview = HBFav2::WebView.new.tap do |v|
      v.frame = CGRectZero
      v.delegate = self
    end
    @webview.loadHTMLString(document, baseURL:nil)
  end

  def viewWillAppear(animated)
    super
    @webview.frame = self.view.frame
  end

  def document
    return <<'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
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
  font-family: serif;
  color: #000;
  font-size: 90%;
}

a {
  text-decoration: none;
  color: #000;
  border-bottom: 1px dotted #ccc;
  padding-bottom: 2px;
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

div.content {
  margin-top: 3em;
  font-size: 100%;
  line-height: 160%;
}
</style>
</head>
<body>
<h1>ややマニアックな機能の紹介</h1>

<div class="content">
<h2>リストから直接エントリを開く</h2>

<p>タイムラインやブックマークのリストで、テーブルのセルを長押し (ロングタップ) すると、コメント画面を介さず直接その記事を開きます。</p>

<h2>スワイプで「戻る」</h2>

<p>ナビゲーションバーに「戻る」ボタンがある画面では、スワイプでボタンを押すのと同じ動作をします。つまり、スワイプで一つ前の画面に戻ります</p>

<h2>ルートまで「戻る」</h2>

<p>ナビゲーションバーの「戻る」ボタンを長押しすると、間に複数画面があった場合でも、ルート (画面遷移の最初) の画面まで一気に戻すことができます。</p>

<h2>コメント画面でアクションを開く</h2>

<p>コメント画面のタイトルを長押しするとアクションメニュー (メールや Twitter などのシェア画面) を開くことができます。</p>

</div>
</body>
</html>
EOF
  end
end
