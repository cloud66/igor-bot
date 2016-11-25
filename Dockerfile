FROM litaio/ruby:2.2.2

VOLUME /opt/chat-ops-common

RUN mkdir /opt/lita
RUN chmod u=rwx /opt/lita
WORKDIR /opt/lita

RUN echo "gem: --no-ri --no-rdoc" > /.gemrc && \
    gem install bundler

ADD . /opt/lita
RUN bundle install

CMD ./hold_lita.sh
