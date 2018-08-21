# Pre-define ARGs to ensure correct scope
ARG WEBHOOK_VER=2.6.8

FROM alpine:3.8 as builder

ARG WEBHOOK_VER

ENV GOPATH /go
ENV SRCPATH ${GOPATH}/src/github.com/adnanh/webhook

WORKDIR ${SRCPATH}

RUN apk add -U curl go git libc-dev gcc libgcc \
 && curl -L https://github.com/adnanh/webhook/archive/${WEBHOOK_VER}.tar.gz \
        | tar xz --strip-components=1 \
 && go get -d \
 && go build -o /webhook \
 && chmod +x /webhook

# =============

FROM spritsail/alpine:3.8

ARG WEBHOOK_VER

LABEL maintainer="Spritsail <webhook@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Webhook" \
      org.label-schema.url="https://github.com/adnanh/webhook/" \
      org.label-schema.description="Run shell commands from a simple HTTP API" \
      org.label-schema.version=${WEBHOOK_VER} \
      io.spritsail.version.webhook=${WEBHOOK_VER}

WORKDIR /

COPY --from=builder /webhook /usr/bin/webhook

RUN apk add -U --no-cache bash

EXPOSE 9000

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/webhook"]

