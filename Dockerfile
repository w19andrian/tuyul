# =========== BUILD STAGE =========== #
FROM golang:alpine AS BUILD

ENV APP_NAME=tuyul

ARG VERSION
ARG STAGE

RUN \
    apk update && apk upgrade && \
    apk add gcompat make

WORKDIR /opt/tuyul

COPY ./ .

RUN go mod tidy && make build

# =========== RUNTIME =========== #
FROM alpine AS RUNTIME

ENV TUYUL_ADDR=0.0.0.0
ENV TUYUL_PORT=3000

WORKDIR /opt/bin

COPY --from=build /opt/tuyul/bin/tuyul ./

RUN adduser --disabled-password --gecos '' tuyul

USER tuyul

EXPOSE 3000

CMD ["./tuyul"]