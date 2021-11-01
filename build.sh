#!/bin/sh

apt update
apt install -y --no-install-recommends wget git curl \
  build-essential libffi-dev libssl-dev \
  zlib1g-dev liblzma-dev libbz2-dev libreadline-dev \
  libsqlite3-dev ca-certificates
apt upgrade -y
git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
$PYENV_ROOT/plugins/python-build/install.sh
/usr/local/bin/python-build -v $PYTHON_VERSION $PYTHON_ROOT
rm -rf $PYENV_ROOT
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
poetry config virtualenvs.create false
poetry install
poetry add "mlflow==${mlflow_version}"
apt remove -y build-essential git wget curl
apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
rm -rf $HOME/.poetry
rm -rf /var/lib/apt/lists/*
find /usr/local -depth 		\( 			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) 			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) 		\) -exec rm -rf '{}' +
find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' 		| awk '/=>/ { print $(NF-1) }' 		| sort -u 		| xargs -r dpkg-query --search 		| cut -d: -f1 		| sort -u 		| xargs -r apt-mark manual
