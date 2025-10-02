#!/usr/bin/env bash
set -euo pipefail

echo "[dods] Installing/updating Day of Defeat: Source server..."

bash "${STEAMCMDDIR}/steamcmd.sh" \
        +force_install_dir "${STEAMAPPDIR}" \
				+login anonymous \
				+app_update 232290 \
        validate \
				+quit

if [ -f "${STEAMAPPDIR}/dod/cfg/server.cfg" ]; then
        # Change hostname on first launch (you can comment this out if it has done its purpose)
        sed -i -e 's/{{SERVER_HOSTNAME}}/'"${DODS_HOSTNAME}"'/g' "${STEAMAPPDIR}/dod/cfg/server.cfg"
fi

cd "${STEAMAPPDIR}"

echo "[dods] Starting server on port $SERVER_PORT with name '$SERVER_NAME'..."

bash "${STEAMAPPDIR}/srcds_run" -game dod \
  +fps_max "${DODS_FPSMAX}" \
  -tickrate "${DODS_TICKRATE}" \
  -port "${DODS_PORT}" \
  +tv_port "${DODS_TV_PORT}" \
  +maxplayers "${DODS_MAXPLAYERS}" \
  +map "${DODS_STARTMAP}" \
  +rcon_password "${DODS_RCONPW}" \
  +sv_password "${DODS_PW}" \
  +servercfgfile "${DODS_CFG}" \
  +mapcyclefile "${DODS_MAPCYCLE}"
