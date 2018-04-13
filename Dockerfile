FROM alpine:latest
MAINTAINER Justin Dray <justin@dray.id.au>

RUN apk add --no-cache openvpn openssl

RUN wget https://torguard.net/downloads/OpenVPN-UDP.zip && \
    unzip OpenVPN-UDP.zip

WORKDIR /OpenVPN-UDP

COPY openvpn.sh /usr/local/bin/openvpn.sh

ENV REGION="Australia.Sydney"
ENTRYPOINT ["openvpn.sh"]
