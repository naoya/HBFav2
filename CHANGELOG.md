# 2.5 / _In Review_

* コピーしたURLを開く機能追加
* プレースホルダ(ブックマークをもっと読む)からの新着取得時に位置がずれる不具合を修正
* URL scheme を hbfav2:// から hbfav:// へ変更 (@toshiwo)

# 2.4 / 2013-11-03

* iOS SDK 7.0 対応
* URL scheme : hbfav:/entry/http://example.com/... に対応 (@toshiwo)

## 細かな修正

* ブックマークコメント取得時のタイムアウトを 10sec -> 30sec に
* レビューを書くリンク切れ修正
* メモリ不足時に NSURLCache のキャッシュをクリア

## Thanks to our contributors

* [Toshiwo][toshiwo]

# 2.3 / 2013-09-17

* 人気コメント
* コメント画面 (BookmarkView) に description とサムネイルを表示
* アプリ利用時の通知オン/オフ設定追加
* プッシュ通知の形式を MPNotificationView に再度変更
* Google Analytics 組み込み

# 2.2 / 2013-09-17

* プッシュ通知
* ブックマーク追加をSDKのUIに変更
* 人気/新着エントリー画面のデザイン変更
* Pixate 依存を解消 (@Watson1978)
* ユーザー設定時に 403/404 をチェック
* 「開発者より」画面追加
* リモート画像取得時のパフォーマンス改善
    * SDWebImage -> AFNetworking
* 「Chromeで開く」追加
* 長押しでルートまで戻る機能改善
    * 閉じるボタンの長押しにも対応

## バグ修正

* はてなブックマークエントリーAPIを余計に呼んでいたのを修正
* 24時間表記オフ設定でのクラッシュを修正
* マナーモード時に動画を開いたとき音が鳴るように修正
* サイドメニューのセレクションが時々外れるのを修正
* formotion 1.3.1 -> 1.4.0 (SDKとの相性バグ修正のため)

## ほか

* 新しいバージョンがあったら通知
* APIのエンドポイントを hbfav.herokuapp.com -> feed.hbfav.com へ変更
* APIキーを environment.yaml に外出し
* キャッシュの影響に伴う意図しない動作を改善
* プロフィール画面をなくし直接ブックマークを開くように変更
    * 現状「フォロー」を見たい場面がほとんどないため
    * ユーザーに対するアクションを定義するときにプロフィール画面を再検討する

## Thanks to our contributors

* [Watson][Watson1978]

# 2.1 / 2013-08-17

## 新機能

* アプリアイコンを変更 (@ugtkbtk)
* サイドメニューを追加
* コメント欄のリンク、はてなID、Twitter名をクリッカブルに
* バグレポート機能・設定を追加 (デフォルトオフ)
* テーブルセル長押しで直接 WebView を開くように
* 戻るボタン長押しで root View まで戻るように
* PermalinkViewController で titleButton を長押しでアクションが開くように
* スワイプで戻る機能追加
* Readability モードにフォントサイズ変更機能を追加
* 「このアプリについて」画面追加

## 細かな変更

* WebView にプログレスバーを追加
* Pocket のログアウト設定を追加
* リスト、コメント画面のフォントサイズを小さく (16pt -> 15pt)
* rm-wsse を 0.0.4 に変更

## Thanks to our contributors

* [Yuji Takabatake][ugtkbtk]

# 2.0 / 2013-08-01

* RubyMotion で書き直してリリース

## Thanks to our contributors

* [Takeshi Nagayama][nagayama]
* [Watson][Watson1978]

[nagayama]:https://github.com/nagayama
[Watson1978]:https://github.com/Watson1978
[ugtkbtk]:https://github.com/ugtkbtk
[toshiwo]:https://github.com/toshiwo
