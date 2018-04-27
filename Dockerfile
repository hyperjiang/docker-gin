FROM hyperjiang/golang:1.10.1 as golang

ARG APP

WORKDIR /go/src/${APP}

# Prepare 3rd party library files
ADD src/Gopkg.lock src/Gopkg.toml /go/src/${APP}/
RUN mkdir -p /go/src/${APP}/vendor
RUN dep ensure -v -vendor-only

# Build golang code
ADD ./src /go/src/${APP}
WORKDIR /go/src/${APP}

RUN GOOS=linux go build -o /tmp/main .

FROM gcr.io/distroless/base
COPY --from=golang /tmp/main /main
ENTRYPOINT ["/main"]
