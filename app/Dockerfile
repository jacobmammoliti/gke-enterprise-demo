FROM golang:1.23 AS builder

WORKDIR /app

COPY go.mod go.sum src/main.go ./

RUN go mod download && CGO_ENABLED=0 GOOS=linux go build -o /main

FROM scratch

COPY --from=builder /main /

USER 1000

CMD ["/main"]