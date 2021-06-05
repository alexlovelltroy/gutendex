FROM python:3
ARG build_application_name=gutendex


RUN apt-get update && apt-get install -y wait-for-it build-essential postgresql postgresql postgresql-server-dev-all \
&& rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
RUN mkdir /static
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
COPY . /code/


ENV DATABASE_NAME=${build_application_name}-db
ENV DATABASE_USER=${build_application_name}-user
ENV DATABASE_PASSWORD=${build_application_name}-pass
ENV DATABASE_HOST=${build_application_name}-host
ENV DATABASE_PORT=5432
ENV STATIC_ROOT=/static
ENV MEDIA_ROOT=/media

ENV EMAIL_HOST = 'smtp.sendgrid.net'
ENV EMAIL_HOST_USER = 'apikey' # this is exactly the value 'apikey'
ENV EMAIL_HOST_PASSWORD = SENDGRID_API_KEY
ENV EMAIL_PORT = 587
ENV EMAIL_USE_TLS = True
ENV EMAIL_HOST_ADDRESS = ${build_application_name}@${build_application_name}.com


RUN SECRET_KEY=mysecret python manage.py collectstatic

# Configure custom entrypoint to run migrations
COPY docker/entrypoint.sh /usr/local/bin/custom-entrypoint
RUN chmod u+x /usr/local/bin/custom-entrypoint
ENTRYPOINT ["custom-entrypoint"]

EXPOSE 8000
CMD ["runserver", "0.0.0.0:8000"]
