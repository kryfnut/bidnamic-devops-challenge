FROM python:3.11-rc-alpine AS build

# RUN useradd -ms /bin/bash app_user

# USER app_user

WORKDIR /usr/src/app

ENV FLASK_APP=bidnamic-app.py

COPY requirements.txt requirements.txt

RUN apk update && pip3 install virtualenv

RUN virtualenv -p python3 venv && . venv/bin/activate

RUN pip3 install -r requirements.txt

COPY src/* . 

EXPOSE 80

ENTRYPOINT [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]