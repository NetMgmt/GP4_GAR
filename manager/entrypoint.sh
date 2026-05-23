#!/bin/bash
# entrypoint.sh — Script de arranque del Manager

echo "=============================================="
echo "  GP4 - Manager (Ansible)"
echo "  IP: 10.0.125.2"
echo "=============================================="
echo ""
echo "  Conectarte:  docker exec -it manager bash"
echo ""
echo "  Ficheros relevantes:"
echo "    /etc/ansible/hosts         <- inventario [servers]"
echo "    /etc/ansible/ansible.cfg   <- config Ansible"
echo "    ~/.ssh/id_rsa              <- clave privada RSA"
echo ""
echo "  Comandos útiles:"
echo "    ansible servers -m ping"
echo "    ansible servers -m shell -a 'ps -aux'"
echo "    ansible servers -m copy -a \"src=/etc/hosts dest=/tmp/hosts\""
echo "    ansible-console servers"
echo "    ansible-playbook snmpv3.yml -f 2"
echo "=============================================="
echo ""

echo "[*] Esperando a que host1 y host2 levanten SSH..."
for HOST in 10.0.125.3 10.0.125.4; do
    echo -n "    $HOST ..."
    for i in $(seq 1 30); do
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
            -i /home/vagrant/.ssh/id_rsa vagrant@$HOST exit 2>/dev/null && break
        echo -n "."
        sleep 2
    done
    echo " OK"
done

echo ""
echo "[*] Manager listo. Prueba de conectividad:"
ansible servers -m ping
echo ""
echo "[*] Manager listo. Conéctate con: docker exec -it -u vagrant manager bash"

tail -f /dev/null
