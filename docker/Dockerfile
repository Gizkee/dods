FROM cm2network/steamcmd:root

ENV STEAMAPPDIR "${HOMEDIR}/dods-dedicated"

COPY entry.sh "${HOMEDIR}/entry.sh"
COPY cfg "${STEAMAPPDIR}/dod/cfg"

RUN set -x \
    mkdir -p "${STEAMAPPDIR}" \
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh"

WORKDIR "${HOMEDIR}"

EXPOSE 27015/udp \
    27015/tcp \
    27020/udp

ENV DODS_HOSTNAME="New DoD:S Server" \
    DODS_TICKRATE=66 \
	DODS_PORT=27015 \
	DODS_TV_PORT=27020 \
	DODS_MAXPLAYERS=16 \
	DODS_RCONPW="changeme" \
	DODS_PW="changeme" \
	DODS_STARTMAP="dod_argentan" \
	DODS_CFG="server.cfg" \
	DODS_MAPCYCLE="mapcycle.txt" \
    DODS_FPSMAX=300

CMD ["bash", "entry.sh"]
