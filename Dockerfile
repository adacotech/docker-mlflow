FROM ubuntu:22.04

ENV APP_PATH /opt/apps
ENV HOME /root
ENV PYTHON_VERSION 3.9.13
ENV PYTHON_ROOT /usr/local/python-$PYTHON_VERSION
ENV PATH $PYTHON_ROOT/bin:$HOME/.poetry/bin:$PATH
ENV PYENV_ROOT $HOME/.pyenv
ENV DEBIAN_FRONTEND noninteractive
ARG mlflow_version

# install module
# install python
# poetry install
WORKDIR ${APP_PATH}
COPY . ${APP_PATH}
RUN ./build.sh
ENTRYPOINT [ "sh", "-c"]
CMD ["mlflow server --host=0.0.0.0"]
