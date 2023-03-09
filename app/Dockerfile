# Use Alpine Linux with Python 3.8.latest preinstalled as base Image
# https://hub.docker.com/_/python
FROM python:3.8-alpine

# Set workdir inside container
WORKDIR /srv/app

# Update Environment Path variable
ENV PATH="${PATH}:/srv/app"

# Copy requirements file to image
COPY ./requirements.txt /srv/app/requirements.txt


# Install dependencies for building PostgreSQL client (also needed for build psycopg2)
# Update Python pip from 20 to latest
# Install Python dependencies and packages from the requirements file
RUN \
  apk add --no-cache postgresql-libs && \
  apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev && \
  python3 -m pip install --upgrade pip && \
  python3 -m pip install -r requirements.txt --no-cache-dir && \
  apk --purge del .build-deps


# Copy "web.py" and "web.conf" to image
COPY ./web.py /srv/app/web.py
COPY ./conf/web.conf /srv/app/conf/web.conf


# Run app from container
ENTRYPOINT ["python"]
CMD ["web.py"]
