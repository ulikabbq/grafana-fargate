# Maintainer: github.com/ulikabbq
# https://github.com/grafana/grafana-docker
# note that there is a breaking change to this if you go above version 5.0.4
# the chamber install breaks on 5.0.5 and up. 
FROM grafana/grafana:5.0.4

# Install chamber
ENV CHAMBER_VERSION=2.0.0
ENV CHAMBER_SHA256SUM=bdff59df90a135ea485f9ce5bcfed2b3b1cc9129840f08ef9f0ab5309511b224
RUN curl -Ls https://github.com/segmentio/chamber/releases/download/v${CHAMBER_VERSION}/chamber-v${CHAMBER_VERSION}-linux-amd64 > chamber-linux-amd64 && \
    echo "${CHAMBER_SHA256SUM}  chamber-linux-amd64" > chamber_SHA256SUMS && \
    sha256sum -c chamber_SHA256SUMS && \
    rm chamber_SHA256SUMS && \
    chmod +x chamber-linux-amd64 && \
    mv chamber-linux-amd64 /usr/local/bin/chamber

# Let chamber export secrets as env variables during startup
ENTRYPOINT ["chamber", "exec", "grafana", "--", "/run.sh"]