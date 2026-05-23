# GP4 — Gestión de configuración mediante Ansible
## Escenario Docker para la práctica de laboratorio

---

## Topología

```
manager (10.0.125.2)
   │
   ├── SSH/Ansible ──► host1 (10.0.125.3)
   └── SSH/Ansible ──► host2 (10.0.125.4)
```

| Contenedor | IP           | Rol                        |
|------------|--------------|----------------------------|
| manager    | 10.0.125.2   | Nodo de control Ansible    |
| host1      | 10.0.125.3   | Nodo gestionado (agente)   |
| host2      | 10.0.125.4   | Nodo gestionado (agente)   |

---

## Arranque del escenario

```bash
# Construir imágenes y arrancar (primera vez tarda ~2-3 min)
docker compose up -d --build

# Seguir el proceso de arranque del manager (copia de claves SSH)
docker compose logs -f manager

# Verificar que los tres contenedores están corriendo
docker compose ps
```

> El manager espera automáticamente a que host1 y host2 levanten SSH,
> luego copia su clave pública RSA en ambos hosts. Cuando veas
> `[*] Manager listo` en los logs, el entorno está preparado.

---

## Conectarse a los hosts

```bash
docker exec -it -u vagrant manager bash   # nodo de control (SIEMPRE como vagrant)
docker exec -it host1 bash                # nodo gestionado 1
docker exec -it host2 bash                # nodo gestionado 2
```

> **Importante:** el manager debe usarse siempre con `-u vagrant`. Sin ello entras como
> `root` y la clave SSH está en `/home/vagrant/.ssh/`, por lo que Ansible y SSH fallarán.

---

## Parte 1 — Verificar la instalación de Ansible

```bash
docker exec -it manager bash

# Comprobar versión instalada
ansible --version

# Ver el inventario configurado
cat /etc/ansible/hosts

# Comprobar conectividad SSH manual con host1 y host2
ssh vagrant@10.0.125.3
ssh vagrant@10.0.125.4
```

---

## Parte 2 — Uso básico de Ansible

```bash
docker exec -it manager bash

# Módulo ping: verificar conectividad Ansible con todos los hosts del grupo
ansible servers -m ping

# Módulo shell: ejecutar un comando remoto en paralelo
ansible servers -m shell -a 'ps -aux'

# Módulo copy: copiar un fichero a todos los hosts
ansible servers -m copy -a "src=/etc/hosts dest=/tmp/hosts"

# Consola interactiva remota sobre el grupo servers
ansible-console servers
```

---

## Parte 3 — Configurar SNMPv3 con un playbook

Los ficheros de ejemplo están en `parte3_ejemplo/`. Cópialos al manager y complétalos:

```bash
# Copiar los ficheros de ejemplo al manager
docker cp parte3_ejemplo/snmpd.conf  manager:/home/vagrant/snmpd.conf
docker cp parte3_ejemplo/snmpv3.yml  manager:/home/vagrant/snmpv3.yml
docker cp parte3_ejemplo/snmp.conf   manager:/home/vagrant/snmp.conf

# Conectarse al manager y editar el playbook
docker exec -it manager bash
nano ~/snmpv3.yml       # completar los TODO
```

### Ejecutar el playbook

```bash
ansible-playbook snmpv3.yml -f 2
```

### Verificar el resultado en host1 / host2

```bash
# Desde el manager: consulta SNMPv3 completa
# NOTA: en Docker snmpd escucha en el puerto 1161 (no 161)
# En un entorno real con Vagrant el puerto sería 161
snmpget -v 3 -u vagrant -l authPriv -a SHA -A vagrant1234 \
        -x AES -X vagrant1234 10.0.125.3:1161 SNMPv2-MIB::sysUpTime.0

# Desde host1/host2: ver la configuración copiada
docker exec -it host1 bash
sudo cat /etc/snmp/snmpd.conf
sudo tail /var/log/syslog
```

### Configurar parámetros por defecto (paso 4)

```bash
docker exec -it -u vagrant manager bash
mkdir -p ~/.snmp
nano ~/.snmp/snmp.conf   # completar los TODO

# Una vez configurado, la consulta se simplifica a:
# (el puerto :1161 sigue siendo necesario en Docker)
snmpget 10.0.125.3:1161 SNMPv2-MIB::sysUpTime.0
```

---

## Parte 4 — Instalar servicios con Ansible (libre)

Crea la carpeta `parte4/` dentro del manager con tu playbook. Ejemplo de estructura
para un servidor web con Flask + MySQL:

```
parte4/
├── site.yml             ← playbook principal
├── inventory            ← inventario (o usa /etc/ansible/hosts)
└── roles/
    ├── mysql/
    │   ├── tasks/main.yml
    │   └── templates/my.cnf.j2
    └── flask/
        ├── tasks/main.yml
        ├── handlers/main.yml
        └── templates/app.conf.j2
```

```bash
ansible-playbook parte4/site.yml -f 2
```

---

## Parar el escenario

```bash
docker compose down
```

---

## Estructura de ficheros entregables

Según el guión, el ZIP `GR_P4.zip` debe contener:

```
GR_P4.zip
├── GP4_traps_respuestas.pdf   ← respuestas partes 1 y 2
├── parte3/
│   ├── hosts                  ← /etc/ansible/hosts
│   ├── ansible.cfg            ← /etc/ansible/ansible.cfg
│   ├── snmpd.conf             ← fichero de configuración SNMP
│   ├── snmpv3.yml             ← playbook
│   └── snmp.conf              ← ~/.snmp/snmp.conf del manager
└── parte4/
    └── ...                    ← estructura de ficheros Ansible
```
