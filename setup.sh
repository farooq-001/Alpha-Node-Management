sudo apt update
sudo apt install python3 python3-pip
cd /home/opt/NodeManagement
python3 -m venv myenv
pip3 install flask paramiko  gunicorn

sudo nano /etc/systemd/system/alpha-nodes.service

[Unit]
Description=Gunicorn instance to serve Alpha Nodes
After=network.target

[Service]
#User=snb-tech
#Group=snb-tech
WorkingDirectory=/opt/NodeManagement
ExecStart=/opt/NodeManagement/myenv/bin/gunicorn -w 4 -b 0.0.0.0:80 alpha-nodes:app
Restart=always

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl start alpha-nodes
sudo systemctl enable alpha-nodes
