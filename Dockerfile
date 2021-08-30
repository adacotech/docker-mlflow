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
# install python
# poetry install
WORKDIR ${APP_PATH}
COPY . ${APP_PATH}
RUN apt update \
 && apt install -y --no-install-recommends wget git \
  build-essential libffi-dev libssl-dev \
  zlib1g-dev liblzma-dev libbz2-dev libreadline-dev \
  libsqlite3-dev ca-certificates \
 && apt upgrade -y \
 && git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT \
 && $PYENV_ROOT/plugins/python-build/install.sh \
 && /usr/local/bin/python-build -v $PYTHON_VERSION $PYTHON_ROOT \
 && rm -rf $PYENV_ROOT \
 && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - \
 && find /usr/local -depth 		\( 			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) 			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) 		\) -exec rm -rf '{}' + 	\
 && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' 		| awk '/=>/ { print $(NF-1) }' 		| sort -u 		| xargs -r dpkg-query --search 		| cut -d: -f1 		| sort -u 		| xargs -r apt-mark manual \
 && pip install poetry \
 && poetry config virtualenvs.create false \
 && poetry add PyMySQL psycopg2-binary "mlflow==${mlflow_version}" boto3 mleap google-cloud-storage scikit-learn azure-storage-blob \
 && apt remove -y build-essential git wget \
 && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
 && rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "sh", "-c"]
CMD ["poetry run mlflow server --host=0.0.0.0"]
