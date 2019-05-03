FROM golang:latest
MAINTAINER tombuildsstuff

RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN GO111MODULE=on go build -mod=vendor -o main .

EXPOSE 8080
CMD [ "/app/main" ]
