FROM litaio/ruby:2.2.2

RUN mkdir /opt/lita
WORKDIR /opt/lita
VOLUME /opt/lita

RUN echo "gem: --no-ri --no-rdoc" > /.gemrc && \
    gem install bundler

ADD . /opt/lita
RUN bundle install

CMD lita start
