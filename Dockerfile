FROM litaio/ruby:2.2.2

RUN mkdir /opt/lita
WORKDIR /opt/lita
VOLUME /opt/lita

ADD setup.sh setup.sh
RUN echo "gem: --no-ri --no-rdoc" > /.gemrc && \
    gem install lita -v 4.4.3 && \
    gem install lita-slack

ADD run.sh run.sh
CMD ./setup.sh && ./run.sh
