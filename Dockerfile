# https://docs.docker.com/language/python/build-images/
FROM python:3.9.6-slim-buster

ENV FLASK_APP=login_form
ENV SECRET_KEY=dev

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

RUN chmod +x scripts/*

EXPOSE 5000

CMD ["./scripts/entrypoint.sh"]
