FROM ubuntu:23.10 as platform

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN apt-get install -y nodejs

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
COPY install-vela.sh /bin/install-vela.sh
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk -U upgrade \
    && apk add --no-cache ca-certificates lrzsz vim \
    && ln -s /usr/bin/lrz	/usr/bin/rz \
    && ln -s /usr/bin/lsz	/usr/bin/sz \
    && /bin/install-ttyd.sh \
    && /bin/install-vela.sh

COPY --from=builder /app/dist/inline.html index.html
ENTRYPOINT ttyd
