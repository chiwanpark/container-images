#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
USERNAME="${_REMOTE_USER:-root}"

apt-get update
apt-get install -y --no-install-recommends rocm-smi rocminfo
apt-get clean
rm -rf /var/lib/apt/lists/*

install -d /usr/local/share/rocm-feature
cat > /usr/local/share/rocm-feature/entrypoint.sh <<EOF
#!/usr/bin/env bash
username="${USERNAME}"

if [ "\$(id -u)" = "0" ] && [ "\${username}" != "root" ]; then
  for device in /dev/kfd /dev/dri/*; do
    [ -e "\${device}" ] || continue
    gid=\$(stat -c '%g' "\${device}")
    [ "\${gid}" != "0" ] || continue
    group=\$(getent group "\${gid}" | cut -d: -f1)
    if [ -z "\${group}" ]; then
      group="rocm-host-\${gid}"
      groupadd -g "\${gid}" "\${group}"
    fi
    usermod -aG "\${group}" "\${username}"
  done
fi

exec "\$@"
EOF
chmod 0755 /usr/local/share/rocm-feature/entrypoint.sh
