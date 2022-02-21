FROM python:3.10.2-alpine3.15

RUN apk update && pip3 install virtualenv

COPY requirements.txt requirements.txt

RUN virtualenv -p python3 venv && . venv/bin/activate

RUN pip3 install -r requirements.txt

RUN addgroup -S appuser && adduser -S appuser -G appuser

USER appuser

WORKDIR /usr/src/app

ENV FLASK_APP=app.py

COPY src/* . 

EXPOSE 5000

ENTRYPOINT [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]