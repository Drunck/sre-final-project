FROM node:12.21.0-buster-slim as base

LABEL maintainer="Eero Ruohola <eero.ruohola@shuup.com>"

RUN apt-get update \
    && apt-get --assume-yes install \
        libffi-dev \
        libpangocairo-1.0-0 \
        python3 \
        python3-pip \
        vim \
    && rm -rf /var/lib/apt/lists/ /var/cache/apt/

COPY . /app
WORKDIR /app

RUN pip3 install -U pip  \
    && pip3 install -U setuptools  \
    && pip3 install shuup  \
    && pip3 install markupsafe==2.0.1 \
    && pip3 install django-prometheus

RUN python3 -m shuup_workbench migrate
RUN python3 -m shuup_workbench shuup_init

RUN echo '\
from django.contrib.auth import get_user_model\n\
from django.db import IntegrityError\n\
try:\n\
    get_user_model().objects.create_superuser("admin", "admin@admin.com", "admin")\n\
except IntegrityError:\n\
    pass\n'\
| python3 -m shuup_workbench shell

CMD ["python3", "-m", "shuup_workbench", "runserver", "0.0.0.0:8000"]
