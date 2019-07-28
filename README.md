Rails APP Template
================================

- Railsのテンプレート機能を用いたひな型からRailsアプリを作成します。最低限のgemとrubocopを設定し、簡単なサンプルアプリがあるものを作成するので素早くRailsアプリを立ち上げて実験したり開発を始めることができます。
- 参照）ApplicationTemplateのススメ(onk) https://www.slideshare.net/takafumionaka/applicationtemplate
- ubuntu19.04 Ruby2.6.3 Rails5.2.3で動作確認済み
- folk from https://github.com/onk/rails_app_template
- 変更箇所
  - 引数でアプリ名指定できるようにしました
  - erb, minitest派です
  - DB指定なくしています
  - rubocop-railsを利用するためにonkcopから独自のrubocop.ymlを利用しています
  - いくつか利用gemを足しています

使い方
--------------------------------

```sh
# Railsアプリを置きたいディレクトリに移動する
$ git clone https://github.com/daaaaaai/rails_app_template.git
$ sh rails_app_template/create_rails_app.sh APP_NAME
```

