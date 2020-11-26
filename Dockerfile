FROM ruby:2.7.2-slim
LABEL maintainer="Mahito Ogura <earthdragon77@gmail.com>"

RUN apt-get update && apt-get install -y build-essential
RUN mkdir /opt/nework-notify
ADD ./lib /opt/nework-notify/lib
ADD Gemfile /opt/nework-notify/
ADD Gemfile.lock /opt/nework-notify/

WORKDIR /opt/nework-notify
RUN gem install bundler
RUN bundle install

CMD ["bundle", "exec", "ruby", "lib/nework-notify.rb"]
