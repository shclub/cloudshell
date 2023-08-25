FROM ubuntu:23.10 as builder

RUN apt-get update && apt-get install -y git curl nodejs npm build-essential essential

RUN curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh | bash nodesource_setup.sh
# RUN apt-get install -y nodejs
RUN npm install -g yarn

RUN git clone --depth=1 https://github.com/cloudtty/cloudtty && \
    cp -r cloudtty/html/ /app/
WORKDIR /app
RUN /usr/local/bin/yarn install
RUN /usr/local/bin/yarn run build

COPY install-ttyd.sh /bin/install-ttyd.sh
RUN curl -fsSLO https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-09-19-013247/openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && tar xvfz openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && chmod +x oc \
    && mv oc /usr/local/bin \
    && rm -rf openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz
RUN /bin/install-ttyd.sh

COPY --from=builder /app/dist/inline.html index.html
ENTRYPOINT ttyd
