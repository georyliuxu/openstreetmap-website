FROM ruby:2.5.3
RUN apt-get update && apt-get install -qy nodejs postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*
# 设置 Rails 版本
ENV RAILS_VERSION 5.2.3
# 安装 Rails
RUN gem install rails --version ${RAILS_VERSION}
 
ENV HOME /home/app

RUN mkdir -p ${HOME}

WORKDIR ${HOME}

ADD . ${HOME}
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/

RUN apt-get upate && \
        apt-get install -y ruby2.5 libruby2.5 ruby2.5-dev libmagickwand-dev libxml2-dev libxslt1-dev nodejs \
        apache2 apache2-dev build-essential git-core \
        postgresql postgresql-contrib libpq-dev postgresql-server-dev-all \
        libsasl2-dev imagemagick libffi-dev && \
        cp config/example.database.yml config/database.yml && \
        bundle install --deployment && \
	    bundle exec rails assets:precompile

# 启动 web 应用
CMD ["bundle","exec","rails","s"]

# 创建代码所运行的目录 
#RUN mkdir -p /usr/src/app 
#WORKDIR /usr/src/app
# 使 webserver 可以在容器外面访问
EXPOSE 3000

# 安装所需的 gems 
ADD Gemfile /home/app/Gemfile  
ADD Gemfile.lock /home/app/Gemfile.lock  
RUN bundle install --without development test
RUN gem2.5 install bundler
# 运行 rake 任务
RUN RAILS_ENV=production rake db:create db:migrate 




