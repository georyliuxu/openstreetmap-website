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
ENV TZ=Asia/Shanghai
RUN apt-get update && apt-get install -y --no-install-recommends tzdata
#RUN apt-get install -y sudo
#RUN apt-get update
#RUN echo "Asia/Shanghai" > /etc/timezone && \
#    dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -y ruby2.5 libruby2.5 ruby2.5-dev libmagickwand-dev  \
    libxml2-dev libxslt1-dev \
    nodejs  apache2 apache2-dev build-essential git-core \
    postgresql postgresql-contrib libpq-dev postgresql-server-dev-all  \
    libsasl2-dev imagemagick libffi-dev 
RUN gem2.5 install bundler  
RUN gem install bundler --version '1.17.2'
RUN cd /home/app
RUN git clone https://github.com/openstreetmap/openstreetmap-website.git
RUN cd openstreetmap-website && bundle install
WORKDIR ${HOME}/openstreetmap-website
RUN cp config/example.database.yml config/database.yml && cp config/settings.yml config/settings.local.yml

#RUN ls /etc/init.d/
#RUN /etc/init.d/postgresql start

#RUN sudo -u postgres -i
#RUN sudo -u postgres psql 
#RUN ALTER USER postgres WITH PASSWORD '123456';
#RUN \q
#RUN createuser -s postgres
#RUN exit
#RUN bundle exec rake db:create
#RUN psql -d openstreetmap -p 5432 -h 127.0.0.1 -c "CREATE EXTENSION btree_gist"
#RUN apt-get install -y wget
#RUN wget http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.6.tar.gz
#RUN tar zxvf ncurses-5.6.tar.gz  && cd ncurses-5.6 && ./configure -prefix=/usr/local -with-shared-without-debug && make && make install
RUN cd db/functions &&  make libpgosm.so && cd ../..
#RUN ln db/functions/libpgosm.so /tmp
#RUN service iptables stop
#RUN psql -d openstreetmap -p 5432 -h 127.0.0.1  -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT"
#RUN psql -d openstreetmap -p 5432 -h 127.0.0.1 -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT"
#RUN psql -d openstreetmap -p 5432 -h 127.0.0.1 -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT"
#RUN bundle exec rake db:migrate
RUN bundle exec rake i18n:js:export
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




