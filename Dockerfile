FROM ruby:2.2

ENV LITA_VERSION 4.3.2
ENV LITA_INFO_LEVEL debug
ENV SLACK_TOKEN YOUR_SLACK_TOKEN
ENV REDIS_HOST 127.0.0.1
ENV REDIS_PORT 6379

RUN mkdir /opt/lita

WORKDIR /opt/lita
VOLUME /opt/lita

ADD setup.sh setup.sh

RUN gem install lita -v ${LITA_VERSION} && \
    gem install lita-slack

CMD /opt/lita/setup.sh && lita start
