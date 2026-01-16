#!/bin/bash


if [[ -z "$1" ]] 
then
    echo "Please specify go version as first argument"
    exit 1;
fi

export GO_VERSION=$1

DOCKERFILE=vulncheck/Dockerfile

cat << 'EOF' > "$DOCKERFILE"
ARG GO_VERSION=1
FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:${GO_VERSION}-bookworm

ARG VERSION=local
ARG TARGETOS
ARG TARGETARCH

COPY . /app
WORKDIR /app
RUN go get
RUN go install golang.org/x/vuln/cmd/govulncheck@latest
CMD govulncheck ./...
EOF


docker build --build-arg GO_VERSION="${GO_VERSION}" -t scuttle-vulncheck --file "$DOCKERFILE" .
docker run -it --rm scuttle-vulncheck