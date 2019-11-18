#!/usr/bin/env bash

# Setting Vault Address, it is running on localhost at port 8200
export VAULT_ADDR=http://127.0.0.1:8200

# Setting the Vault Address in Vagrant user bash profile
grep "VAULT_ADDR" ~/.bash_profile  > /dev/null 2>&1 || {
echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ~/.bash_profile
}

echo "Check if Vault is already initialized..."
if [ `vault status -address=${VAULT_ADDR}| awk 'NR==4 {print $2}'` == "true" ]
then
    echo "Vault already initialized...Exiting..."
    exit 1
fi

# Making working dir for Vault setup
mkdir -p /home/vagrant/_vaultSetup
touch /home/vagrant/_vaultSetup/keys.txt

echo "Setting up PKI admin user..."

echo "Initializing Vault..."
vault operator init -address=${VAULT_ADDR} > /home/vagrant/_vaultSetup/keys.txt
export VAULT_TOKEN=$(grep 'Initial Root Token:' /home/vagrant/_vaultSetup/keys.txt | awk '{print substr($NF, 1, length($NF))}')

echo "Unsealing vault..."
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 1:' /home/vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 2:' /home/vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 3:' /home/vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1

echo "Auth with root token..."
vault login -address=${VAULT_ADDR} token=${VAULT_TOKEN} > /dev/null 2>&1

# Enabling userpass auth method.
echo "Enabling userpass auth method."
vault auth enable -address=${VAULT_ADDR} userpass > /dev/null 2>&1

# Enabling logging to a file
echo "Enabling logging to a file"
sudo touch /var/log/auditVault.log
sudo chown vault:vault /var/log/auditVault.log
vault audit enable file file_path=/var/log/auditVault.log

# Enable ssh secret backend at ssh-client/ path
echo "Enable ssh secret backend at ssh-client/ path"
vault secrets enable -path=ssh-client ssh

# Generating CA key for signing client's public keys.
echo "Generating CA key for signing client's public keys."
vault write \
  -field=public_key \
  ssh-client/config/ca \
  generate_signing_key=true \
  | sudo tee /etc/ssh/trusted-user-ca-keys.pem > /dev/null 2>&1

# Entering the Vault CA generated cert as trusted by SSH daemon, every public key signed by it should be able to log on.
echo "Entering the Vault CA generated cert as trusted by SSH daemon, every public key signed by it should be able to log on"
echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem" | sudo tee -a /etc/ssh/sshd_config

# Checking if sshd_config looks ok

sudo sudo sshd -t 

if [ $? -eq 0 ] 
then 
    echo "The /etc/sshd_config file looks good...move on"
else
    echo "Something went terrably wrong...exiting"
    exit 1
fi

# Reload SSHD to pick up the changes
echo "Reload SSHD to pick up the changes"
sudo systemctl reload sshd

# Creating regular and root roles in SSH secret backend
echo "Creating regular and root roles in SSH secret backend"
vault write ssh-client/roles/regular @/vagrant/configs/roles/regular-user-role.hcl 

vault write ssh-client/roles/root @/vagrant/configs/roles/root-user-role.hcl

# Creating regular and root Vault polices
echo "Creating regular and root Vault polices"
vault policy write ssh-regular-user-policy /vagrant/configs/policies/regular-user-role-policy.hcl

vault policy write ssh-root-user-policy /vagrant/configs/policies/root-user-role-policy.hcl

# Enabling userpass for ssh clients 
echo "Enabling userpass for ssh clients"
vault auth enable -path=ssh_userpass userpass > /dev/null 2>&1

# Creating regular and root users in userpass dedicated to ssh clients
echo "Creating regular and root users in userpass dedicated to ssh clients"
vault write auth/ssh_userpass/users/withoutroot \
  password="withoutroot" \
  policies="ssh-regular-user-policy" > /dev/null 2>&1


vault write auth/ssh_userpass/users/withroot \
  password="withroot" \
  policies="ssh-regular-user-policy,ssh-root-user-policy" > /dev/null 2>&1

# Adding ubuntu user
sudo useradd ubuntu





