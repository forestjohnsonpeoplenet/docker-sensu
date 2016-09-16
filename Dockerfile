FROM ubuntu:16.04
MAINTAINER Forest Johnson <fjohnson@peoplenetonline.com>

RUN \
    apt-get update &&\
    apt-get install -y curl ca-certificates &&\ 
    rm -rf /var/lib/apt/lists/*

RUN curl -s http://repositories.sensuapp.org/apt/pubkey.gpg | apt-key add -
RUN echo "deb     http://repositories.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

ENV SENSU_VERSION=0.26.1-1
RUN \
	apt-get update && \
    apt-get install -y sensu=${SENSU_VERSION} && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /opt/sensu/embedded/bin:$PATH

#Nokogiri is needed by aws plugins
RUN \
	apt-get update && \
    apt-get install -y libxml2 libxml2-dev libxslt1-dev zlib1g-dev libunwind8 libicu55 build-essential  && \
    gem install --no-ri --no-rdoc nokogiri yaml2json && \
    apt-get remove -y libxml2-dev libxslt1-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*


ENV ENVTPL_VERSION=0.2.3
RUN \
    curl -Ls https://github.com/arschles/envtpl/releases/download/${ENVTPL_VERSION}/envtpl_linux_amd64 > /usr/local/bin/envtpl && \
    curl -s 'https://github-cloud.s3.amazonaws.com/releases/49609581/1434e3dc-7b5c-11e6-8375-31fdcb64a7cd.deb?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJMK3TQ%2F20160916%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20160916T210049Z&X-Amz-Expires=300&X-Amz-Signature=aa52fa486cd3915a0352bb5bd7d37d03b5f736cb0cce86ec1b89fd1d2c257743&X-Amz-SignedHeaders=host&actor_id=19273873&response-content-disposition=attachment%3B%20filename%3Dpowershell_6.0.0-alpha.10-1ubuntu1.16.04.1_amd64.deb&response-content-type=application%2Foctet-stream' -o powershell_6.0.0-alpha.10-1ubuntu1.16.04.1_amd64.deb && \
    dpkg -i powershell_6.0.0-alpha.10-1ubuntu1.16.04.1_amd64.deb && \
    rm powershell_6.0.0-alpha.10-1ubuntu1.16.04.1_amd64.deb && \
    chmod +x /usr/local/bin/envtpl

COPY templates /etc/sensu/templates
COPY bin /bin/

ENV DEFAULT_PLUGINS_REPO=sensu-plugins \
    DEFAULT_PLUGINS_VERSION=master \
    
    #Client Config
    CLIENT_SUBSCRIPTIONS=all,default \
    CLIENT_BIND=127.0.0.0 \
    CLIENT_DEREGISTER=true \

    #Common Config 
    RUNTIME_INSTALL='' \
    LOG_LEVEL=warn \
    CONFIG_FILE=/etc/sensu/config.json \
    CONFIG_DIR=/etc/sensu/conf.d \
    CHECK_DIR=/etc/sensu/check.d \
    EXTENSION_DIR=/etc/sensu/extensions \
    PLUGINS_DIR=/etc/sensu/plugins \
    HANDLERS_DIR=/etc/sensu/handlers \

    #Config for gathering host metrics
    HOST_DEV_DIR=/dev \
    HOST_PROC_DIR=/proc \
    HOST_SYS_DIR=/sys

RUN mkdir -p $CONFIG_DIR $CHECK_DIR $EXTENSION_DIR $PLUGINS_DIR $HANDLERS_DIR

EXPOSE 4567
VOLUME ["/etc/sensu/conf.d"]

ENTRYPOINT ["/bin/start"]
