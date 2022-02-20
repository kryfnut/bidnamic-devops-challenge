FROM alpine:latest AS build

RUN useradd app_user

USER app_user

WORKDIR /usr/src/app

COPY requirements.txt requirements.txt

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    net-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 

RUN apt-get install shadow-utils

RUN pip3 install -r requirements.txt

COPY src/* . 

EXPOSE 80

ENTRYPOINT [ "python", "./bidnamic-app.py" ]