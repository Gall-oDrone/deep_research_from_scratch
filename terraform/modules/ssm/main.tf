# SSM Document for IDE Bootstrap
resource "aws_ssm_document" "bootstrap" {
  name            = "${var.environment}-bootstrap"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: "2.2"
description: "Bootstrap IDE instance with code-server and Jupyter"
mainSteps:
  - action: aws:runShellScript
    name: BootstrapIDE
    inputs:
      timeoutSeconds: 1800
      runCommand:
        - |
          #!/bin/bash
          set -e
          
          echo "Starting bootstrap process..."
          
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
          
          # Install Jupyter and related packages
          pip3 install --user jupyter jupyterlab notebook ipykernel pandas numpy matplotlib seaborn scikit-learn
          
          # Create Jupyter configuration
          mkdir -p ~/.jupyter
          cat > ~/.jupyter/jupyter_notebook_config.py <<'JUPYTER_CONFIG'
          import os
          from jupyter_core.paths import jupyter_data_dir
          
          c = get_config()
          c.NotebookApp.ip = '0.0.0.0'
          c.NotebookApp.port = 8888
          c.NotebookApp.open_browser = False
          c.NotebookApp.allow_root = True
          c.NotebookApp.allow_origin = '*'
          c.NotebookApp.token = ''
          c.NotebookApp.password = ''
          c.NotebookApp.notebook_dir = '/home/ec2-user/environment'
          c.NotebookApp.enable_mathjax = True
          c.NotebookApp.trust_xheaders = True
          c.NotebookApp.disable_check_xsrf = True
          JUPYTER_CONFIG
          
          # Create systemd service for Jupyter
          sudo tee /etc/systemd/system/jupyter.service <<'JUPYTER_SERVICE'
          [Unit]
          Description=Jupyter Notebook Server
          After=network.target
          
          [Service]
          Type=simple
          User=ec2-user
          WorkingDirectory=/home/ec2-user/environment
          ExecStart=/home/ec2-user/.local/bin/jupyter notebook --config=/home/ec2-user/.jupyter/jupyter_notebook_config.py
          Restart=always
          RestartSec=10
          
          [Install]
          WantedBy=multi-user.target
          JUPYTER_SERVICE
          
          sudo systemctl daemon-reload
          sudo systemctl enable jupyter
          sudo systemctl start jupyter
          
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
          
          # Create a test notebook
          mkdir -p ~/environment/notebooks
          cat > ~/environment/notebooks/test.ipynb <<'TEST_NOTEBOOK'
          {
           "cells": [
            {
             "cell_type": "markdown",
             "metadata": {},
             "source": [
              "# Test Jupyter Notebook\\n",
              "\\n",
              "This is a test notebook to verify that Jupyter is working correctly."
             ]
            },
            {
             "cell_type": "code",
             "execution_count": null,
             "metadata": {},
             "outputs": [],
             "source": [
              "import pandas as pd\\n",
              "import numpy as np\\n",
              "import matplotlib.pyplot as plt\\n",
              "\\n",
              "print(\\"Jupyter is working!\\")\\n",
              "print(f\\"Pandas version: {pd.__version__}\\")\\n",
              "print(f\\"NumPy version: {np.__version__}\\")"
             ]
            }
           ],
           "metadata": {
            "kernelspec": {
             "display_name": "Python 3",
             "language": "python",
             "name": "python3"
            },
            "language_info": {
             "codemirror_mode": {
              "name": "ipython",
              "version": 3
             },
             "file_extension": ".py",
             "mimetype": "text/x-python",
             "name": "python",
             "nbconvert_exporter": "python",
             "pygments_lexer": "ipython3",
             "version": "3.9.0"
            }
           },
           "nbformat": 4,
           "nbformat_minor": 4
          }
          TEST_NOTEBOOK
          
          echo "Bootstrap completed successfully!"
          EOT
DOC

  tags = merge(var.common_tags, {
    Name = "${var.environment}-bootstrap-document"
  })
}
