#!/bin/sh

# usage
# sh create_rails_app.sh APP_NAME

if [ $# != 1 ]; then
    echo "アプリ名を引数に指定してください"
    exit 1
fi

APP_NAME=$1
EDGE=0
mkdir "${APP_NAME}"
cd ./"${APP_NAME}"

git init .

cat <<EOF > Gemfile
source "https://rubygems.org"
gem "rails"
EOF

git add Gemfile
git commit -n -m "first commit"

bundle install --path ~/.bundle --binstubs=~/.bundle/bin --jobs=4 --without=
git add -A
git commit -n -m "add rails and bundle install"

bundle exec rails new . --force -m ../rails_app_template/rails_template.rb --skip-bundle
