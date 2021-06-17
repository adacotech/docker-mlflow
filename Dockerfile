FROM ubuntu:20.04

ENV APP_PATH /opt/apps
ENV HOME /root
ENV PYTHON_VERSION 3.9.5
ENV PYTHON_ROOT /usr/local/python-$PYTHON_VERSION
ENV PATH $PYTHON_ROOT/bin:$PATH
ENV PYENV_ROOT $HOME/.pyenv
ENV DEBIAN_FRONTEND noninteractive
ARG mlflow_version

# install module
RUN apt update
RUN apt install -y wget unzip git bash \
  build-essential libffi-dev libssl-dev \
  zlib1g-dev liblzma-dev libbz2-dev libreadline-dev \
  libsqlite3-dev libicu-dev mesa-utils mysql-client \
  libjpeg-dev libtiff-dev

RUN apt upgrade -y

# install python
RUN git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT \
 && $PYENV_ROOT/plugins/python-build/install.sh \
 && /usr/local/bin/python-build -v $PYTHON_VERSION $PYTHON_ROOT \
 && rm -rf $PYENV_ROOT

# poetry install
RUN pip install poetry

WORKDIR ${APP_PATH}
COPY . ${APP_PATH}
RUN poetry config virtualenvs.create false
RUN poetry add PyMySQL psycopg2-binary "mlflow==${mlflow_version}" boto3 mleap google-cloud-storage scikit-learn azure-storage-blob
ENTRYPOINT [ "sh", "-c"]
CMD ["poetry run mlflow server --host=0.0.0.0"]
