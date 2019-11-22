# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT

echo "Installing dependencies ..."
sudo apt-get update
sudo apt-get install -y unzip curl jq dnsutils vim htop net-tools

echo "Determining Consul version to install ..."
CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
if [ -z "$CONSUL_DEMO_VERSION" ]; then
    CONSUL_DEMO_VERSION=$(curl -s "${CHECKPOINT_URL}"/consul | jq .current_version | tr -d '"')
fi

echo "Fetching Consul version ${CONSUL_DEMO_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_DEMO_VERSION}/consul_${CONSUL_DEMO_VERSION}_linux_amd64.zip -o consul.zip

echo "Installing Consul version ${CONSUL_DEMO_VERSION} ..."
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul

sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d

sudo useradd consul | true

SCRIPT

$consul_systemd = <<CONSUL_SYSTEMD

cat <<EOT > /etc/systemd/system/consul.service
[Unit]
Description=Consul
After=network.target
Requires=network.target

[Service]
Environment=CONSUL_UI_BETA=true
ExecStartPre=/bin/mkdir -p /var/lib/consul
ExecStartPre=/bin/chown -R consul. /var/lib/consul
ExecStart=/usr/bin/consul agent -server -retry-join ${CONSUL_BOOTSTRAP_HOST}  -client 0.0.0.0 -bootstrap-expect 3 -ui -raft-protocol=3 -datacenter=${DC} -advertise=${HOSTIP} -data-dir=/var/lib/consul -node=${HOSTNAME} -retry-join-wan=${CONSUL_BOOTSTRAP_HOST_WAN}
ExecStop=/usr/bin/consul leave
ExecReload=/usr/bin/consul reload
PermissionsStartOnly=true
Restart=always
RestartSec=1
User=consul

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl restart consul

CONSUL_SYSTEMD

# Specify a Consul version
CONSUL_DEMO_VERSION = ENV['CONSUL_DEMO_VERSION']

# Specify a custom Vagrant box for the demo
DEMO_BOX_NAME = ENV['DEMO_BOX_NAME'] || "debian/stretch64"

# Dummy constants
hostip = (10..15).map { |i| "172.20.20.#{i}" }

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = DEMO_BOX_NAME

  config.vm.provision "shell", inline: $script, env: {'CONSUL_DEMO_VERSION' => CONSUL_DEMO_VERSION}

  (0..5).each do |i|
    config.vm.define "n#{i}" do |node|
        node.vm.hostname = "n#{i}"
        CONSUL_BOOTSTRAP_HOST ||= hostip[i]
        if i % 2 == 0
          dc = "mmm"
          CONSUL_BOOTSTRAP_HOST_1 ||= hostip[i]
          CONSUL_BOOTSTRAP_HOST_WAN_2 ||= hostip[i+1]
          consul_bootstrap_host = CONSUL_BOOTSTRAP_HOST_1
          consul_bootstrap_host_wan = CONSUL_BOOTSTRAP_HOST_WAN_2
        else
          dc = "nnn"
          CONSUL_BOOTSTRAP_HOST_2 ||= hostip[i]
          CONSUL_BOOTSTRAP_HOST_WAN_1 ||= hostip[i-11]
          consul_bootstrap_host = CONSUL_BOOTSTRAP_HOST_2
          consul_bootstrap_host_wan = CONSUL_BOOTSTRAP_HOST_WAN_1
        end
        node.vm.network "private_network", ip: hostip[i]
        node.vm.provision "shell", inline: $consul_systemd, env: {"CONSUL_BOOTSTRAP_HOST": consul_bootstrap_host, "CONSUL_BOOTSTRAP_HOST_WAN": consul_bootstrap_host_wan, "HOSTIP" => hostip[i], "DC" => dc}
    end
  end

end
