FROM alpine:latest
MAINTAINER Justin Dray <justin@dray.id.au>

RUN apk add --no-cache openvpn openssl

RUN wget https://torguard.net/downloads/OpenVPN-UDP-Linux.zip && \
    unzip OpenVPN-UDP-Linux.zip

WORKDIR /OpenVPN-UDP

COPY openvpn.sh /usr/local/bin/openvpn.sh

ENV REGION="Australia.Sydney"
ENTRYPOINT ["openvpn.sh"]
