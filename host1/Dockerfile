FROM ubuntu:22.04

LABEL description="GP4 - Host1: nodo gestionado por Ansible"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    vim \
    nano \
    net-tools \
    iproute2 \
    iputils-ping \
    snmpd \
    snmp \
    rsyslog \
    && rm -rf /var/lib/apt/lists/*

# Usuario vagrant con sudo sin contraseña
RUN useradd -m -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Clave pública del manager precargada — Ansible puede entrar sin contraseña
RUN mkdir -p /home/vagrant/.ssh && chmod 700 /home/vagrant/.ssh
COPY authorized_keys /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys && \
    chown -R vagrant:vagrant /home/vagrant/.ssh

# SSH: permitir autenticación por clave, deshabilitar contraseña
RUN mkdir /var/run/sshd && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

RUN mkdir -p /etc/snmp

EXPOSE 22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
