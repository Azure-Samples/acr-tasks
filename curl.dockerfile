FROM alpine:latest
RUN apk add curl
ENTRYPOINT ["/usr/bin/curl"]