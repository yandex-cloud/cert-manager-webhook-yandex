FROM golang:1.26.5-alpine3.24 AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

ENV GOOS=linux
ENV GOARCH=amd64

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM gcr.io/distroless/static:nonroot

COPY --from=build /workspace/webhook /usr/local/bin/webhook

USER nonroot:nonroot

ENTRYPOINT ["webhook"]
