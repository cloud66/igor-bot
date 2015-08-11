FROM litaio/ruby:2.2.2

RUN mkdir /opt/lita
WORKDIR /opt/lita
VOLUME /opt/lita

ADD . /opt/lita
RUN bundle install

CMD lita start
