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

cat > /etc/consul.d/client/config.json << STOP_IT

{
    "bind_addr": "${BIND_ADDR}",
    "server": false,
    "datacenter": "vagrant",
    "data_dir": "/var/consul",
    "encrypt": "X4SYOinf2pTAcAHRhpj7dA==",
    "log_level": "INFO",
    "enable_syslog": true,
    "enable_script_checks": true,
    "start_join": ["${NODE1}", "${NODE2}", "${NODE3}"]
}
STOP_IT

cat > /etc/consul.d/client/postgresql.json << STOP_IT
{
  "service": {
    "name": "postgresql",
    "tags": ["Follower"],
    "port": 5432,
    "checks":
    [{
    "id": "pg-alive",
    "notes": "Make sure connect and queries work",
    "script": "/usr/local/bin/check_postgresql",
    "interval": "10s"
    }]
  }
}
STOP_IT

chown -R consul:consul /var/consul
chown -R consul:consul /etc/consul.d


cat > /usr/local/bin/check_postgresql << STOP_IT
#!/usr/bin/env bash
echo 0;
STOP_IT


chmod 777 /usr/local/bin/check_postgresql
