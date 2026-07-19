#!/bin/bash
set -e

USER_UID=${PUID:-1000}
USER_GID=${PGID:-1000}
USER_NAME=${USER_NAME:-"chiwanpark"}

# remap user id, group id and username.
if getent group "${USER_GID}" >/dev/null 2>&1; then
  :
elif getent group "${USER_NAME}" >/dev/null 2>&1; then
  groupmod -g "${USER_GID}" "${USER_NAME}"
else
  groupadd -g "${USER_GID}" "${USER_NAME}"
fi
if getent passwd "${USER_UID}" >/dev/null 2>&1; then
  USER_NAME=$(getent passwd "${USER_UID}" | cut -d: -f1)
  usermod -g "${USER_GID}" "${USER_NAME}"
else
  if getent passwd "${USER_NAME}" >/dev/null 2>&1; then
    usermod -u "${USER_UID}" -g "${USER_GID}" "${USER_NAME}"
  else
    useradd -u "${USER_UID}" -g "${USER_GID}" -m -s /bin/zsh "${USER_NAME}"
  fi
fi
USER_HOME=$(getent passwd "${USER_NAME}" | cut -d: -f6)

# Allow the configured user to run sudo without a password.
printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "${USER_NAME}" > "/etc/sudoers.d/${USER_NAME}"
chmod 0440 "/etc/sudoers.d/${USER_NAME}"

# Add the current user to "docker" group if the socket is accessible.
if [ -S /var/run/docker.sock ]; then
  DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
  DOCKER_GROUP=$(getent group "${DOCKER_GID}" | cut -d: -f1)
  if [ -z "${DOCKER_GROUP}" ]; then
    DOCKER_GROUP="docker-host"
    if getent group "${DOCKER_GROUP}" >/dev/null 2>&1; then
      DOCKER_GROUP="docker-host-${DOCKER_GID}"
    fi
    groupadd -g "${DOCKER_GID}" "${DOCKER_GROUP}"
  fi
  usermod -aG "${DOCKER_GROUP}" "${USER_NAME}"
fi

PERSIST_DIR=${PERSIST_DIR:-"/mnt/persistent"}
for dir in .pi .claude .gemini .codex .paseo; do
  persistent_path="${PERSIST_DIR}/${dir}"
  home_path="${USER_HOME}/${dir}"

  mkdir -p "${persistent_path}"
  if [ -e "${home_path}" ] && [ ! -L "${home_path}" ]; then
    printf 'Cannot link %s: the path already exists and is not a symbolic link\n' \
      "${home_path}" >&2
    exit 1
  fi
  ln -sfn "${persistent_path}" "${home_path}"
done

# Avoid rewriting ownership metadata that is already correct. Do not cross into
# nested mounts that may exist below the persistent or home directories.
find "${PERSIST_DIR}" "${USER_HOME}" -xdev \
  \( ! -uid "${USER_UID}" -o ! -gid "${USER_GID}" \) \
  -exec chown -h "${USER_UID}:${USER_GID}" {} +

# Run user configuration scripts as the configured user.
CONFIG_STATE_DIR="${USER_HOME}/.local/state/container-config"
gosu "${USER_NAME}" mkdir -p "${CONFIG_STATE_DIR}"
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
    gosu "${USER_NAME}" env HOME="${USER_HOME}" USER="${USER_NAME}" LOGNAME="${USER_NAME}" \
      /bin/bash "${script}"

    # Only record completion after the script succeeds. The cumulative hash
    # reruns this script if it or an earlier dependency changes in a new image.
    marker_tmp="${completion_marker}.tmp.$$"
    gosu "${USER_NAME}" /bin/bash -c \
      'printf "%s\n" "$1" > "$2" && mv "$2" "$3"' \
      _ "${config_hash}" "${marker_tmp}" "${completion_marker}"
  fi
done

exec gosu "${USER_NAME}" env HOME="${USER_HOME}" USER="${USER_NAME}" LOGNAME="${USER_NAME}" \
  SHELL="/bin/zsh" "${@}"
