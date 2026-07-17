#!/bin/bash
set -e

USERID=${USERID:-1000}
GID=${USERID:-1000}
USERNAME=${USERNAME:-"chiwanpark"}

# remap user id, group id and username.
if ! getent group "${USERID}" >/dev/null 2>&1; then
  groupadd -g ${USERID} ${USERNAME}
fi
if ! getent passwd "${USERID}" >/dev/null 2>&1; then
  useradd -u "${USERID}" -g "${GID}" -m -s /bin/zsh ${USERNAME}
fi

# Allow the configured user to run sudo without a password.
printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "${USERNAME}" > "/etc/sudoers.d/${USERNAME}"
chmod 0440 "/etc/sudoers.d/${USERNAME}"

# Add the current user to "docker" group if the socket is accessible.
if [ -S /var/run/docker.sock ]; then
  DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
  EXISTING_GRP=$(getent group "${DOCKER_GID}" | cut -d: -f1)
  if [ -n "${EXISTING_GROUP}" ]; then 
    usermod -aG "${EXISTING_GROUP}" ${USERNAME}
  else
    groupadd -g "${DOCKER_GID}" docker
    usermod -aG docker ${USERNAME}
  fi
fi

# Run user configuration scripts as the configured user.
USER_HOME=$(getent passwd "${USERNAME}" | cut -d: -f6)
for script in /etc/config-local/*.sh; do
  if [ -f "${script}" ]; then
    echo "Running ${script}"
    gosu "${USERNAME}" env HOME="${USER_HOME}" USER="${USERNAME}" LOGNAME="${USERNAME}" \
      /bin/bash "${script}"
  fi
done

exec gosu "${USERNAME}" "${@}"
