FROM ubuntu:22.04

LABEL description="GP4 - Manager: nodo de gestión Ansible"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ansible \
    openssh-client \
    sshpass \
    vim \
    nano \
    net-tools \
    iproute2 \
    iputils-ping \
    snmp \
    snmp-mibs-downloader \
    && rm -rf /var/lib/apt/lists/*

# Usuario vagrant con sudo sin contraseña
RUN useradd -m -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Clave SSH fija
RUN mkdir -p /home/vagrant/.ssh && chmod 700 /home/vagrant/.ssh
COPY id_rsa     /home/vagrant/.ssh/id_rsa
COPY id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
RUN chmod 600 /home/vagrant/.ssh/id_rsa && \
    chmod 644 /home/vagrant/.ssh/id_rsa.pub && \
    chown -R vagrant:vagrant /home/vagrant/.ssh

# Inventario y config de Ansible — 644 para que vagrant pueda leerlos
RUN mkdir -p /etc/ansible
COPY ansible_hosts /etc/ansible/hosts
COPY ansible.cfg   /etc/ansible/ansible.cfg
RUN chmod 644 /etc/ansible/hosts /etc/ansible/ansible.cfg

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER vagrant
WORKDIR /home/vagrant

ENTRYPOINT ["/entrypoint.sh"]
