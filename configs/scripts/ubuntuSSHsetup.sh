# Setting up Ubuntu SSH server to used TrustedCA# 
#Entering the Vault CA generated cert as trusted by SSH daemon, every public key signed by it should be able to log on.

echo "Copying the CA cert from /vagrant/ folder to /etc/ssh/"
sudo cp /vagrant/trusted-user-ca-keys.pem /etc/ssh/

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

# Adding user ubuntu
sudo useradd ubuntu
