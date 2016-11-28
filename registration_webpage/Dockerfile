FROM node:6.9.1

VOLUME /opt/chat-ops-common

RUN mkdir /opt/igor-bot-registration
WORKDIR /opt/igor-bot-registration
ADD ./registration_webpage /opt/igor-bot-registration

RUN npm install

CMD node server.js
