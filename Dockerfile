FROM ubuntu:23.10 as builder

RUN apt-get update && apt-get install -y git curl nodejs npm build-essential essential vim

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
    && chmod +x {oc,kubectl} \
    && mv {oc,kubectl} /usr/local/bin \
    && rm -rf openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz
RUN /bin/install-ttyd.sh

COPY --from=builder /app/dist/inline.html index.html
ENTRYPOINT ttyd
----
RUN apk -U upgrade \
    && apk add --no-cache ca-certificates bash git openssh curl gettext jq \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl -O /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -O - | tar -xzO ${TARGETOS}-${TARGETARCH}/helm > /usr/local/bin/helm \
    && wget -q https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${TARGETOS}_${TARGETARCH} -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/yq \
    && mkdir /config \
    && chmod g+rwx /config /root \
    && helm repo add "stable" "https://charts.helm.sh/stable" --force-update \
    && kubectl version --client \
    && helm version

WORKDIR /config

CMD bash
