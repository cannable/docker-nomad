FROM centos:8

ARG NOMAD_VERSION
ARG NOMAD_VERSION=1.0.1

ENV NAME nomad

COPY ["./data", "/data"]

RUN ["/bin/bash", "/data/build-nomad.sh"]

VOLUME ["/var/nomad", "/etc/nomad.d"]

# Port info can be found here:
# https://www.nomadproject.io/docs/install/production/requirements

# TCP           4646            HTTP(S) API
# TCP           4647            RPC
# TCP/UDP 	4648 	        Serf
# TCP/UDP 	20000-32000     Dynamic ports for things

EXPOSE "4646/tcp" \
       "4647/tcp" \
       "4648/tcp" \
       "4648/udp" \
       "20000-32000/tcp" \
       "20000-32000/udp"

ENTRYPOINT ["/usr/local/bin/nomad"]
CMD ["agent", "-config", "/etc/nomad.d"]
