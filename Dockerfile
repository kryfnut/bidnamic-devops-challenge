FROM python:3.11-rc-alpine AS build

# RUN useradd -ms /bin/bash app_user

# USER app_user

WORKDIR /usr/src/app

COPY requirements.txt requirements.txt

RUN pip3 install virtualenv

RUN virtualenv -p python3 venv && . venv/bin/activate

RUN pip3 install -r requirements.txt

COPY src/* . 

EXPOSE 80

ENTRYPOINT [ "python", "./bidnamic-app.py" ]