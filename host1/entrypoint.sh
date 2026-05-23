#!/bin/bash
echo "=============================================="
echo "  GP4 - Host1 (nodo gestionado por Ansible)"
echo "  IP: 10.0.125.3"
echo "=============================================="

# Generar host keys SSH si no existen
ssh-keygen -A

# Arrancar rsyslog para que /var/log/syslog esté disponible
rsyslogd 2>/dev/null || true

# Arrancar sshd en foreground
echo "[*] Iniciando sshd..."
exec /usr/sbin/sshd -D -e
