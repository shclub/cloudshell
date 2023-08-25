FROM --platform=${BUILDPLATFORM:-linux/amd64} node:18.5.0 as builder
# Build frontend code which added upload/download button
RUN git clone --depth=1 https://github.com/cloudtty/cloudtty && \
    cp -r cloudtty/html/ /app/
WORKDIR /app
RUN yarn install
RUN yarn run build

FROM ubuntu:23.10
RUN apt-get update && apt-get -y install  apt-transport-https ca-certificates curl gnupg lsb-release bash git curl gettext jq vim

# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# RUN echo \
# "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
# $(lsb_release -cs) stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null

# RUN apt-get update && apt-get install docker-ce docker-ce-cli containerd.io gnupg2 pass docker-compose

COPY install-ttyd.sh /bin/install-ttyd.sh

RUN curl -fsSLO https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-09-19-013247/openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && tar xvfz openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && chmod +x {oc,kubectl} \
    && mv {oc,kubectl} /usr/local/bin \
    && rm -rf openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

RUN /bin/install-ttyd.sh
WORKDIR /config

CMD bash

COPY --from=builder /app/dist/inline.html index.html

ENTRYPOINT ttyd
