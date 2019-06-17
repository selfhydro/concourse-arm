FROM arm32v7/debian



# 'web' keys
ENV CONCOURSE_SESSION_SIGNING_KEY     /concourse-keys/session_signing_key
ENV CONCOURSE_TSA_AUTHORIZED_KEYS     /concourse-keys/authorized_worker_keys
ENV CONCOURSE_TSA_HOST_KEY            /concourse-keys/tsa_host_key

# 'worker' keys
ENV CONCOURSE_TSA_PUBLIC_KEY          /concourse-keys/tsa_host_key.pub
ENV CONCOURSE_TSA_WORKER_PRIVATE_KEY  /concourse-keys/worker_key

# enable DNS proxy to support Docker's 127.x.x.x DNS server
ENV CONCOURSE_GARDEN_DNS_PROXY_ENABLE         true
ENV CONCOURSE_WORKER_GARDEN_DNS_PROXY_ENABLE  true

# auto-wire work dir for 'worker' and 'quickstart'
ENV CONCOURSE_WORK_DIR                /worker-state
ENV CONCOURSE_WORKER_WORK_DIR         /worker-state

# volume for non-aufs/etc. mount for baggageclaim's driver
VOLUME /worker-state

RUN apt-get update && apt-get install -y \
    btrfs-tools \
    ca-certificates \
    dumb-init \
    iproute2 \
    file \
    wget

COPY *.tgz /tmp
RUN tar xzf /tmp/*.tgz -C . && mv ./linux-rc /usr/local

RUN ls -laR /usr/local/

STOPSIGNAL SIGUSR2

ENTRYPOINT ["dumb-init", "/usr/local/concourse_linux_arm"]
