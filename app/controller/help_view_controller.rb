# -*- coding: utf-8 -*-
class HelpViewController < UIViewController
  def viewDidLoad
    super

    self.title = "開発者より"
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
<h1>開発者より</h1>

<div class="content">

<!-- follow -->
<h2>何人くらいをフォローすれば良いか</h2>

<p>Twitterでも数百人くらいフォローするとタイムラインの使用感が変わるとよく言われます。</p>

<p>HBFavを利用するなら、たくさんフォロー(お気に入りユーザー)を増やすと良いでしょう。自分はいまのところ200人強です。これくらいいると、ちょっとした移動時、休憩時、就寝前の暇つぶしには事書きません。</p>

<p>Twitterほどタイムラインの流れは速くありませんが、Twitterに同じく、全部読もうとせずときどき暇なときに開いて面白そうなものをつまみ食いするくらいがちょうど良い使い方なのではないかと思っています。</p>

<p>200人はだいぶ多い方だと思います。まずは40〜50人くらいを目安にしてみるといいかもしれません。</p>

<!-- request -->
<h2>このアプリでできないこと</h2>

<h3>他のユーザーをフォローする</h3>

<p>残念ながら HBFav内で他のユーザーをフォロー(お気に入りに追加)することは、いまのところできません。はてなブックマーク本体にアクセスして追加してください。</p>
<p>はてなブックマークにフォローのAPIがないので実現できていませんが、APIが対応次第、機能追加を行いたいと思っています。</p>

<h3>スターをつける</h3>

<p>面白かったコメントにはスターをつけたいという気持ちになることも多いのですが、これもまだできません。理由はフォローに同じくです。できるようにしたいです。</p>

<!-- option -->
<h2>新ユーザーページオプションの効用</h2>

<p>設定に「新ユーザーページ」のオン/オフがあります。</p>

<p>これをオンにするにははてなブックマーク本体側でも新ユーザーページを利用している必要がありますが、有効にすると、フィードの読み込み方がより望ましい動きになります。</p>

<p>具体的には、ページをまたいだ際にエントリーの重複がなくなり、リロード時に以前に保持したエントリリストは保持したままリロードが行われます。オフの場合はこの両者とも実現できません。</p>

<!-- private -->
<h2>プライベートモードで使えないのはなぜ?</h2>

<p>HBFav は、アプリに必要なデータを主にはてなブックマークの公開RSS フィードを利用しています。</p>
<p>プライベートモードのアカウントではお気に入りユーザーのフィードが取得できないため、HBFav が必要としているデータが集められないのです。ごめんなさい</p>

<!-- crash report -->
<h2>クラッシュレポートにご協力ください</h2>

<p>クラッシュレポートを送る設定がありますが、これを有効にするとアプリがクラッシュした際にクラッシュダンプを開発者に送信することができます。</p>

<p>クラッシュレポートが集まれば、不具合の原因が追及しやすくなるので結果的にアプリの品質を上げやすくなります。</p>

<p>ただし、ネットワーク帯域やプライバシーなどを考慮して初期設定ではクラッシュレポート送信はオフになっています。協力してもよい、という方はお手数ですが設定画面からオンにしていただけると嬉しいです。</p>

<!-- cache -->
<h2>はてな側のキャッシュと本アプリの関係</h2>

<p>本アプリは基本、はてなが公開している各種APIを利用してデータを取得しています。APIの多くはパフォーマンスを考慮して、その出力が一定時間キャッシュされています。従って、例えばアプリ側でブックマークを更新したのにしばらくそのデータがアプリに反映されないとか、ブックマーク数とそれ以外のデータが合わないといったことが起こることがあります。</p>

<p>キャッシュの影響でアプリが意図しないようある程度考慮はしていますが、どうしても難しい部分も多々あります。けいぞくてきに改善していくつもりですが、そういった事情もあることはご理解いただけると嬉しいです。</p>

<!-- tips -->
<h2>ややマニアックな機能の紹介</h2>
<h3>リストから直接エントリを開く</h3>
<p>タイムラインやブックマークのリストで、テーブルのセルを長押し (ロングタップ) すると、コメント画面を介さず直接その記事を開きます。</p>
<h3>スワイプで「戻る」</h3>
<p>ナビゲーションバーに「戻る」ボタンがある画面では、スワイプでボタンを押すのと同じ動作をします。つまり、スワイプで一つ前の画面に戻ります</p>
<h3>ルートまで「戻る」</h3>
<p>ナビゲーションバーの「戻る」ボタンを長押しすると、間に複数画面があった場合でも、ルート (画面遷移の最初) の画面まで一気に戻すことができます。</p>
<h3>コメント画面でアクションを開く</h3>
<p>コメント画面のタイトルを長押しするとアクションメニュー (メールや Twitter などのシェア画面) を開くことができます。</p>

<!-- issues -->
<h2>ご意見・ご要望</h2>

<p>ご意見・ご要望は Github だけでなく開発者の目に付きそうなところにあるものはなるべく検討したいと思っています。</p>

<ul>
  <li>Github の Issue</li>
  <li>Twitter @naoya_ito へのツイート</li>
  <li>開発者ブログへのコメント</li>
</ul>

<p>これらは頻繁にチェックしていますので、ぜひ、よろしくお願いします。</p>

</div>
</body>
</html>
EOF
  end
end
