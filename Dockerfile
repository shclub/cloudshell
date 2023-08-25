FROM ubuntu:23.10 as builder

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN apt-get install -y nodejs

RUN git clone --depth=1 https://github.com/cloudtty/cloudtty && \
    cp -r cloudtty/html/ /app/
WORKDIR /app
RUN yarn install
RUN yarn run build

COPY install-ttyd.sh /bin/install-ttyd.sh
RUN curl -fsSLO https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-09-19-013247/openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && tar xvfz openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && chmod +x oc \
    && mv oc /usr/local/bin \
    && rm -rf openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz
RUN /bin/install-ttyd.sh

COPY /app/dist/inline.html index.html
ENTRYPOINT ttyd
