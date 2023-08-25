FROM --platform=${BUILDPLATFORM:-linux/amd64} node:18.5.0 as builder
# Build frontend code which added upload/download button
RUN git clone --depth=1 https://github.com/cloudtty/cloudtty && \
    cp -r cloudtty/html/ /app/
WORKDIR /app
RUN yarn install
RUN yarn run build

FROM --platform=${BUILDPLATFORM:-linux/amd64} ghcr.io/dtzar/helm-kubectl:3.9
ARG VERSION
ENV BUILDPLATFORM=${BUILDPLATFORM:-linux/amd64}
ENV VERSION=${VERSION}
COPY install-ttyd.sh /bin/install-ttyd.sh
#COPY install-vela.sh /bin/install-vela.sh
RUN curl -fsSLO https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-09-19-013247/openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && tar xvfz openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz \
    && chmod +x oc \
    && mv oc /usr/local/bin \
    && rm -rf kubectl \
    && rm -rf openshift-client-linux-4.7.0-0.okd-2021-09-19-013247.tar.gz
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
# RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/community/" >> /etc/apk/repositories \
RUN echo -e "http://nl.alpinelinux.org/alpine/v3.5/main\nhttp://nl.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories \
    && apk add --no-cache bash ca-certificates  \
    && /bin/install-ttyd.sh 
#    && apk -U upgrade  \
#    && apk add --no-cache ca-certificates lrzsz vim \
#    && ln -s /usr/bin/lrz	/usr/bin/rz \
#    && ln -s /usr/bin/lsz	/usr/bin/sz \
RUN apk add gcompat

COPY --from=builder /app/dist/inline.html index.html
ENTRYPOINT ttyd
