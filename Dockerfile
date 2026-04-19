FROM ruby:3.3.6

# 必要なパッケージ
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  postgresql-client \
  imagemagick \
  libmagickwand-dev \
  fonts-noto-cjk \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gemfile を先にコピー
COPY Gemfile Gemfile.lock package.json package-lock.json ./
RUN gem install bundler
RUN bundle install --without development test
RUN npm install -g yarn
RUN npm install --legacy-peer-deps

# アプリ全体をコピー
COPY . .

# アセットをプリコンパイル（本番必須）
RUN RAILS_ENV=production bundle exec rails assets:precompile

# puma を本番で起動
CMD ["bash", "-c", "bundle exec puma -C config/puma.rb"]