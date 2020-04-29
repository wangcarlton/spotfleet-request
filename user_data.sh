#! /bin/bash
set -x -e
cd ~

yum update -y
# Install AWS inspector as a root user
sudo yum update -y
curl -O https://inspector-agent.amazonaws.com/linux/latest/install
sudo bash install -u false

# Install nodejs environment
cat > /tmp/subscript.sh << EOF
#! /bin/bash
set -x -e
# START
echo "Setting up NodeJS Environment"
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

echo 'export NVM_DIR="/home/ec2-user/.nvm"' >> /home/ec2-user/.bashrc
# Dot source the files to ensure that variables are available within the current shell
. /home/ec2-user/.nvm/nvm.sh

# Install NVM, NPM, Node.JS & Grunt
nvm alias default v14.0.0
nvm install v14.0.0
nvm use v14.0.0

. /home/ec2-user/.bashrc

cd /home/ec2-user/
mkdir test
cd test
npm init -y
npm install express --save

echo "const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => res.send('Test for WAF!'))

app.listen(port, () => console.log('Sever istening at http://localhost:3000'))" >> index.js

node index.js

EOF

chown ec2-user:ec2-user /tmp/subscript.sh && chmod a+x /tmp/subscript.sh
sleep 1;
su - ec2-user -c "/tmp/subscript.sh"