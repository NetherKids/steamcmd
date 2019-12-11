FROM debian:buster-slim
MAINTAINER DJustDE <docker@djust.de>

ENV GAME ttt
ENV STEAMDIR /home/steam
ENV STEAMCMDDIR /home/steam/steamcmd

ENV PORT=27015
ENV PORTTV=27020
ENV CLIENTPORT=27005
ENV SPORT=26900
ENV MAXPLAYERS=12
ENV GAMEMODE=terrortown
ENV MAP=gm_construct
ENV SERVERNAME=
ENV PASSWD=
ENV RCONPASSWD=
ENV WORKSHOPCOLLECTION=
ENV APIKEY=
ENV SERVERACCOUNT=

# --> 27015/tcp=Rcon; 27015/udp=information; 27005/udp=client; 27020/udp=SourceTV; 26900/udp=steam
EXPOSE 27015/tcp 27015/udp 27005/udp 27020/udp 26900/udp 51840/udp

# --> only ARK server
# EXPOSE 7777-7778/tcp 7777-7778/udp
# RUN echo "fs.file-max=100000" >> /etc/sysctl.conf && /
#    echo "* soft nofile 1000000" >> /etc/security/limits.conf && /
#    echo "* hard nofile 1000000" >> /etc/security/limits.conf && /
#    echo "session required pam_limits.so" >> /etc/pam.d/common-session

# ---- >> Server Update
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests lib32stdc++6 lib32gcc1 wget ca-certificates curl screen sudo bash
# ---- >> add user, group steam and add home dir
RUN addgroup --gid 1000 steam && \
    adduser --uid 1000 --ingroup steam --disabled-password --disabled-login steam && \
    mkdir -p ${STEAMDIR}/.steam/sdk32 && cd ${STEAMCMDDIR} && \
    chmod -R 0775 ${STEAMCMDDIR} && \
    chown steam.steam ${STEAMCMDDIR}
# RUN echo 'steam ALL=(ALL) NOPASSWD: ALL' >> '/etc/sudoers'
# --no-create-home ${STEAMCMDDIR}

# ---- >> copy start script
COPY /data ${STEAMDIR}

# ---- >> Install steam cmd
RUN su steam -c "wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" && \
    su steam -c "${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit" && \
    ln -s ${STEAMCMDDIR}/linux32/steamclient.so ${STEAMDIR}/.steam/sdk32/steamclient.so

WORKDIR ${STEAMDIR}
USER steam
VOLUME ${STEAMCMDDIR}
ENTRYPOINT ["${STEAMDIR}/entrypoint"]
