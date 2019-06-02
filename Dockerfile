FROM ubuntu:18.04
RUN apt-get update && apt-get install -qy nodejs postgresql-client sqlite3 --no-install-recommends
# 安装 Rails
#RUN apt-get install -y rails --version ${RAILS_VERSION}
#RUN yum install -y gcc gcc-c++ glibc make autoconf openssl openssl-devel 

ENV HOME /home/app

RUN mkdir -p ${HOME}

WORKDIR ${HOME}

ADD . ${HOME}
#RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/

RUN apt-get update
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y ruby2.5 libruby2.5 ruby2.5-dev libmagickwand-dev  \
    libxml2-dev libxslt1-dev \
    nodejs  apache2 apache2-dev build-essential git-core \
    postgresql postgresql-contrib libpq-dev postgresql-server-dev-all  \
    libsasl2-dev imagemagick libffi-dev 
RUN gem2.5 install bundler  
RUN gem install bundler --version '1.17.2'
RUN cd /home/app
RUN git clone https://github.com/openstreetmap/openstreetmap-website.git
RUN cd openstreetmap-website
RUN bundle install
RUN cp config/example.database.yml config/database.yml
RUN cp config/settings.yml config/settings.local.yml
# RUN sudo -u postgres -i
# RUN createuser -s postgres
# RUN exit
RUN bundle exec rake db:create
RUN psql -d openstreetmap -c "CREATE EXTENSION btree_gist"
RUN cd db/functions
RUN make libpgosm.so
RUN cd ../..
RUN psql -d openstreetmap -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT"
RUN psql -d openstreetmap -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT"
RUN psql -d openstreetmap -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT"
RUN bundle exec rake db:migrate
#RUN bundle exec rake test:db
RUN bundle exec rails assets:precompile
RUN bundle install --deployment

# 启动 web 应用
CMD ["bundle","exec","rails","server"]

# 创建代码所运行的目录 
#RUN mkdir -p /usr/src/app 
#WORKDIR /usr/src/app
# 使 webserver 可以在容器外面访问
EXPOSE 3000




