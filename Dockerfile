FROM python:3.7
# collectstatic needs the secret key to be set. We store that in this environment variable.
# Set this value in this project's .env file
ARG DJANGO_SECRET_KEY

RUN mkdir -p /usr/src/app

COPY ./_app /usr/src/app
#COPY Pipfile /usr/src/app/
#COPY Pipfile.lock /usr/src/app/

WORKDIR /usr/src/app

RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils \
 && apt-get -y install gunicorn3
# && apt-get -y install python3-psycopg2
RUN pip install --upgrade pip \
 && pip install psycopg2-binary \
 && pip install -r requirements.txt.dist

#RUN pip install pipenv
#RUN pipenv install --system --deploy
#RUN python manage.py collectstatic --no-input
