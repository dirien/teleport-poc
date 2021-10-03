#! /bin/bash
curl https://deb.releases.teleport.dev/teleport-pubkey.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://deb.releases.teleport.dev/ stable main'
sudo apt-get update
sudo apt-get install jq
sudo apt-get install teleport

#sudo teleport configure --acme --acme-email=your-email@example.com --cluster-name=tele.example.com -o file

tee /etc/teleport.yaml <<EOF
teleport:
  nodename: teleport
  data_dir: /var/lib/teleport
  log:
    output: stderr
    severity: INFO
    format:
      output: text
  ca_pin: ""
auth_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3025
  cluster_name: ${domain}
ssh_service:
  enabled: "yes"
  labels:
    env: example
  commands:
    - name: hostname
      command: [hostname]
      period: 1m0s
proxy_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3023
  web_listen_addr: 0.0.0.0:443
  kube_listen_addr: 0.0.0.0:3026
  public_addr: ${domain}:443
  https_keypairs: []
  acme:
    enabled: "yes"
    email: ${email}
EOF


tee /etc/systemd/system/teleport.service <<EOF
[Unit]
Description=Teleport Server
Documentation=https://goteleport.com/docs/getting-started/linux-server/

[Service]
WorkingDirectory=/
Type=simple
ExecStart=teleport start --config=/etc/teleport.yaml --pid-file=/run/teleport.pid
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/teleport.pid

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl restart teleport.service
systemctl enable teleport.service