#!/bin/bash
set -e

USERID=${USERID:-1000}
GRPID=${USERID:-1000}
USERNAME=${USERNAME:-"chiwanpark"}

# remap user id, group id and username.
if ! getent group "${GRPID}" >/dev/null 2>&1; then
  groupadd -g ${GRPID} ${USERNAME}
fi
if ! getent passwd "${USERID}" >/dev/null 2>&1; then
  useradd -u "${USERID}" -g "${GRPID}" -m -s /bin/zsh ${USERNAME}
fi

# Allow the configured user to run sudo without a password.
printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "${USERNAME}" > "/etc/sudoers.d/${USERNAME}"
chmod 0440 "/etc/sudoers.d/${USERNAME}"

# Add the current user to "docker" group if the socket is accessible.
if [ -S /var/run/docker.sock ]; then
  DOCKER_GRPID=$(stat -c '%g' /var/run/docker.sock)
  EXISTING_GRP=$(getent group "${DOCKER_GRPID}" | cut -d: -f1)
  if [ -n "${EXISTING_GROUP}" ]; then 
    usermod -aG "${EXISTING_GROUP}" ${USERNAME}
  else
    groupadd -g "${DOCKER_GRPID}" docker
    usermod -aG docker ${USERNAME}
  fi
fi

# Run user configuration scripts as the configured user.
USER_HOME=$(getent passwd "${USERNAME}" | cut -d: -f6)
CONFIG_STATE_DIR="${USER_HOME}/.local/state/container-config"
gosu "${USERNAME}" mkdir -p "${CONFIG_STATE_DIR}"
config_hash=""

for script in /etc/config-local/*.sh; do
  if [ -f "${script}" ]; then
    script_name=$(basename "${script}")
    script_content_hash=$(sha256sum "${script}" | cut -d' ' -f1)
    config_hash=$(printf '%s:%s' "${config_hash}" "${script_content_hash}" | sha256sum | cut -d' ' -f1)
    completion_marker="${CONFIG_STATE_DIR}/${script_name}.sha256"

    if [ -f "${completion_marker}" ] &&
       [ "$(cat "${completion_marker}")" = "${config_hash}" ]; then
      echo "Skipping ${script}; already completed"
      continue
    fi

    echo "Running ${script}"
    gosu "${USERNAME}" env HOME="${USER_HOME}" USER="${USERNAME}" LOGNAME="${USERNAME}" \
      /bin/bash "${script}"

    # Only record completion after the script succeeds. The cumulative hash
    # reruns this script if it or an earlier dependency changes in a new image.
    marker_tmp="${completion_marker}.tmp.$$"
    gosu "${USERNAME}" /bin/bash -c \
      'printf "%s\n" "$1" > "$2" && mv "$2" "$3"' \
      _ "${config_hash}" "${marker_tmp}" "${completion_marker}"
  fi
done

exec gosu "${USERNAME}" env HOME="${USER_HOME}" USER="${USERNAME}" LOGNAME="${USERNAME}" \
  SHELL="/bin/zsh" "${@}"
