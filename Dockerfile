FROM golang:1.16-alpine AS build-env

MAINTAINER Mei Akizuru

# Required for kafka support
RUN apk --no-cache update && \
    apk --no-cache add git gcc libc-dev

# create build env
RUN mkdir -p /go/src/app
WORKDIR /go/src/app

# resolve dependency before copying whole source code
COPY go.mod .
COPY go.sum .
RUN go mod download

# copy other sources & build
COPY . /go/src/app
RUN export GO111MODULE=on
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -tags musl -o /go/bin/app

FROM alpine:3.11 AS runtime-env
COPY --from=build-env /go/bin/app /usr/local/bin/app
ENTRYPOINT ["/usr/local/bin/app"]
