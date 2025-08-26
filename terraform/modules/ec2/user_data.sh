#!/bin/bash
set -e

echo "Starting bootstrap process for ${environment}..."

# Update system
dnf update -y

# Install packages
dnf install -y git tar gzip vim nodejs npm make gcc g++ argon2 python3-pip python3-devel

# Install Docker
dnf install docker -y
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Caddy
dnf copr enable -y @caddy/caddy epel-9-x86_64
dnf install -y caddy
systemctl enable --now caddy

# Setup user environment
cat <<"EOT" | sudo -E -H -u ec2-user bash
set -e

mkdir -p ~/environment

# Install code-server
curl -Ls -o /tmp/coder.rpm https://github.com/coder/code-server/releases/latest/download/code-server-amd64.rpm
sudo rpm -U "/tmp/coder.rpm"
sudo systemctl enable --now code-server@ec2-user

# Install Jupyter
pip3 install --user jupyter jupyterlab notebook ipykernel pandas numpy matplotlib

# Configure code-server
mkdir -p ~/.config/code-server
CODE_SERVER_PASSWORD="workshop123"
HASHED_PASSWORD=$(echo -n "$CODE_SERVER_PASSWORD" | argon2 saltItWithSalt -l 32 -e)

tee ~/.config/code-server/config.yaml <<EOF
cert: false
auth: password
hashed-password: "$HASHED_PASSWORD"
bind-addr: 127.0.0.1:8889
EOF

sudo systemctl restart code-server@ec2-user

echo "Bootstrap completed successfully!"
EOT

echo "Instance ready for SSM commands" > /tmp/instance-ready
