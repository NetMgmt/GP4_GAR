#!/bin/bash
echo "=============================================="
echo "  GP4 - Host2 (nodo gestionado por Ansible)"
echo "  IP: 10.0.125.4"
echo "=============================================="

ssh-keygen -A

rsyslogd 2>/dev/null || true

echo "[*] Iniciando sshd..."
exec /usr/sbin/sshd -D -e
