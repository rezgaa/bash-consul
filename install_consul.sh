#!/usr/bin/env bash
#!/usr/bin/env bash

NODE1=192.168.168.100
NODE2=192.168.168.101
NODE3=192.168.168.102
BIND_ADDR=$(ip ro | grep eth1 | grep src | awk {'print $9'})

adduser consul

wget https://releases.hashicorp.com/consul/1.0.0/consul_1.0.0_linux_amd64.zip

unzip consul_1.0.0_linux_amd64.zip

chmod 777 consul

mv consul /usr/bin

mkdir -p /etc/consul.d/{bootstrap,server,client}

mkdir /var/consul

cat > /etc/consul.d/bootstrap/config.json << STOP_IT
{
    "bind_addr": "${BIND_ADDR}",
    "bootstrap_expect": 3,
    "ui": true,
    "server": true,
    "datacenter": "vagrant",
    "data_dir": "/var/consul",
    "encrypt": "X4SYOinf2pTAcAHRhpj7dA==",
    "log_level": "INFO",
    "enable_syslog": true
}
STOP_IT


cat > /etc/consul.d/server/config.json << STOP_IT

{
    "bind_addr": "${BIND_ADDR}",
    "bootstrap": false,
    "bootstrap_expect": 3,
    "ui": true,
    "server": true,
    "datacenter": "vagrant",
    "data_dir": "/var/consul",
    "encrypt": "X4SYOinf2pTAcAHRhpj7dA==",
    "log_level": "INFO",
    "enable_syslog": true,
    "start_join": ["${NODE2}", "$NODE3"]
}
STOP_IT

cat > /etc/consul.d/client/config.json << STOP_IT

{
    "bind_addr": "${BIND_ADDR}",
    "server": false,
    "datacenter": "vagrant",
    "data_dir": "/var/consul",
    "encrypt": "X4SYOinf2pTAcAHRhpj7dA==",
    "log_level": "INFO",
    "enable_syslog": true,
    "start_join": ["${NODE1}", "${NODE2}", "${NODE3}"]
}
STOP_IT

chown -R consul:consul /var/consul
chown -R consul:consul /etc/consul.d

