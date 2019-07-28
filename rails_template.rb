def git_commit(message, with_rubocop: true)
  if with_rubocop
    Bundler.with_clean_env do
      run "bundle exec rubocop -a"
    end
  end
  git add: "."
  git commit: "-n -m '#{message}'"
end

def bundle_install
  Bundler.with_clean_env do
    run "bundle install --path ~/.bundle --binstubs=~/.bundle/bin --jobs=4 --without="
  end
end

# Windowsで動かすことはない
gsub_file "Gemfile", /^\s*gem\s+["']tzinfo-data["'].*$/, 'gem "tzinfo-data"'

# deprecated
gsub_file "Gemfile", /^(\s*)gem\s+["']chromedriver-helper["'].*$/, "\\1gem \"webdrivers\""

remove_file "Gemfile.lock"
bundle_install
git_commit "rails new", with_rubocop: false

# annotate
gem_group :development do
  gem "annotate"
end
bundle_install
run "rails g annotate:install"
git_commit "add annotate gem", with_rubocop: false

# rubocop
gem_group :development do
  gem "rubocop"
  gem "rubocop-rails"
end
bundle_install
run "curl -o .rubocop.yml -L https://gist.githubusercontent.com/daaaaaai/5c505e8856a78b913ed551077105323f/raw/50536954c8e0c2fd5efec341538afd0450ec9450/.rubocop.yml"

git_commit "add rubocop gem", with_rubocop: false

Bundler.with_clean_env do
  run "bundle exec rubocop -a"
end
git_commit "rubocop -a", with_rubocop: false

# pre-commit
gem_group :development do
  gem "pre-commit"
end
bundle_install
git_commit "add pre-commit gem"

Bundler.with_clean_env do
  run "bundle exec pre-commit install"
  run "bundle exec pre-commit disable yaml checks common rails"
  run "bundle exec pre-commit enable yaml checks rubocop"
end
git_commit "setup pre-commit"

# add pry
gem_group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
  gem 'minitest'
end
bundle_install
git_commit "add pry gems"

# add unicorn
gem "unicorn"
bundle_install
create_file("config/unicorn.rb", <<EOF)
worker_processes 4
listen 3000, tcp_nopush: true
EOF
git_commit "add unicorn gem"

# add test tool
gem_group :test do
  gem 'minitest-reporters'
  gem 'mini_backtrace'
  gem 'guard-minitest'
  gem 'rails-controller-testing'
  gem 'timecop'
end
bundle_install
git_commit "add test gem"

# sample code scaffold
generate :scaffold, "user name birthday:datetime"
rake "db:drop"
rake "db:create"
rake "db:migrate"
git_commit "rails g scaffold user name birthday:datetime"

# scaffold references
# has_one
generate :scaffold, "user_profile user:references gender:integer"
rake "db:migrate"
inject_into_class "app/models/user.rb", "User", <<EOF
  has_one :user_profile, dependent: :destroy
EOF
git_commit "scaffold user_profile with has_one association"
# has_many
generate :scaffold, "article user:references title body:text published_at:datetime"
rake "db:migrate"
inject_into_class "app/models/user.rb", "User", <<EOF
  has_many :articles, dependent: :destroy
EOF
git_commit "scaffold article with has_many association"

# redis-objects
# user has last_logged_in_at
gem "redis-objects"
bundle_install
inject_into_class "app/models/user.rb", "User", <<EOF
  include Redis::Objects
  value :last_logged_in_at
EOF
git_commit "add redis-objects gem"


# scaffold has_many :through models
#   +--------+
#   |  user  |
#   +----+---+
#        |
#   +----+----+  +--------+
#   | article |  | topics |
#   +-------+-+  +-+------+
#           |      |
#         +-+------+-+
#         |  linker  |
#         +----------+
#
generate :scaffold, "topic title"
generate :scaffold, "linker topic:references article:references"
rake "db:migrate"
inject_into_class "app/models/article.rb", "Article", <<EOF
  has_many :linkers, dependent: :destroy
EOF
inject_into_class "app/models/topic.rb", "Topic", <<EOF
  has_many :linkers, dependent: :destroy
  has_many :articles, through: :linkers, dependent: :destroy
EOF
git_commit "scaffold topics, linkers"

# localize
inject_into_file "config/application.rb", <<EOF, after: "# config.time_zone = 'Central Time (US & Canada)'\n"
    config.time_zone = "Tokyo"
EOF
inject_into_file "config/application.rb", <<EOF, after: "# config.i18n.default_locale = :de\n"
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    config.i18n.default_locale = :ja
EOF
run "curl -o config/locales/ja.yml -L https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml"
git_commit "localize to japan"
