ARG python_version
FROM python:${python_version}-slim-buster

WORKDIR /python
COPY ./requirements.txt /python/requirements.txt

RUN pip install -r requirements.txt -t .
