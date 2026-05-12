#
# MailHogPlus Dockerfile
#

FROM golang:1.18-alpine as builder

# Install MailHogPlus:
RUN apk --no-cache add --virtual build-dependencies \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go install github.com/mailhog/MailHog@latest

FROM alpine:3
# Add MailHogPlus user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhogplus

COPY --from=builder /root/gocode/bin/MailHog /usr/local/bin/

USER mailhogplus

WORKDIR /home/mailhogplus

ENTRYPOINT ["MailHog"]

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025
