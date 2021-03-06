FROM debian:stretch-20200803-slim
LABEL version="0.2" maintainer="NetherKids <docker@netherkids.de>"

ARG USER="steam"
ARG GROUP="steam"
ARG UID=27015
ARG GID=27015

ENV USER="${USER}" \
    GROUP="${GROUP}" \
    UID=${UID} \
    GID=${GID} \
    STEAMCMDDIR="/home/steam" \
    SERVERDIR="/opt/server" \
    LANG="en_US.utf8" \
    ULIMIT="2048"

# 

# && apt-get upgrade -y
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests libstdc++6 libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 wget curl ca-certificates gdb python3 python3-requests && \
    addgroup --gid "${GID}" steam && \
    adduser --uid "${UID}" --ingroup "${GROUP}" --disabled-password --disabled-login --gecos "" "${USER}" && \
    chmod 0775 /opt/ && chown steam.steam /opt/ && \
    su steam -c "mkdir -p ${STEAMCMDDIR} ~/.steam/sdk32/ && \
        cd ${STEAMCMDDIR} && \
        wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" && \
    ulimit -n "${ULIMIT}" && \
    apt-get autoremove -y --purge wget && \
    apt-get clean  && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

WORKDIR ${STEAMCMDDIR}
VOLUME ${STEAMCMDDIR}
