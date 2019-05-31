FROM ruby:2.5.3
RUN apt-get update && apt-get install -qy nodejs postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*
# 设置 Rails 版本
ENV RAILS_VERSION 5.2.3
# 安装 Rails
RUN gem install rails --version ${RAILS_VERSION}
#RUN yum install -y gcc gcc-c++ glibc make autoconf openssl openssl-devel 

ENV HOME /home/app

RUN mkdir -p ${HOME}

WORKDIR ${HOME}

ADD . ${HOME}
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/

RUN apt-get upate && \
        apt-get install -y --assume-yes apt-utils ruby2.5 libruby2.5 ruby2.5-dev libmagickwand-dev && \
        apt-get install -y libxml2-dev libxslt1-dev gcc gcc-c++ glibc make && \
        apt-get install -y  nodejs  apache2 apache2-dev build-essential git-core postgresql postgresql-contrib libpq-dev postgresql-server-dev-all && \
        apt-get install -y  libsasl2-dev imagemagick libffi-dev && \
        gem2.5 install bundler && \
        cd /home/app && \
        git clone https://github.com/openstreetmap/openstreetmap-website.git && \
        cd openstreetmap-website && \
        bundle install && \
        cp config/example.database.yml config/database.yml && \
        sudo -u postgres -i && \
        createuser -s postgres && \
        exit && \
        bundle exec rake db:create && \
        psql -d openstreetmap -c "CREATE EXTENSION btree_gist" && \
        cd db/functions && \
        make libpgosm.so && \
        cd ../.. && \
        psql -d openstreetmap -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT" && \
        psql -d openstreetmap -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT" && \
        psql -d openstreetmap -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT" && \
        bundle exec rake db:migrate && \
        bundle exec rake test:db && \
        bundle install --deployment && \
	bundle exec rails assets:precompile

# 启动 web 应用
CMD ["bundle","exec","rails","server"]

# 创建代码所运行的目录 
#RUN mkdir -p /usr/src/app 
#WORKDIR /usr/src/app
# 使 webserver 可以在容器外面访问
EXPOSE 3000




