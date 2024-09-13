# Alpha-Node-Management

git clone https://github.com/farooq-001/Alpha-Node-Management.git

cd Alpha-Node-Management

chmod +x setup.sh

./setup.sh

pip3 show flask paramiko gunicorn

# Add the nodes:
nano nodes.conf

#N1,0.0.0.0,<username>,<password>

N1,127.0.0.0,bfarooq,123456

N2,127.0.0.1,bfarooq,123456

#ect....
