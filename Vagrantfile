Vagrant.configure("2") do |config|

  config.vm.define "vault_server" do |vault_server|
    vault_server.vm.hostname = "vault-server"
    vault_server.vm.box = "martinhristov90/vault"
    vault_server.vm.provision "shell", path: "./configs/scripts/vaultSetupSSH.sh", privileged: false
    vault_server.trigger.after :destroy do |trigger|
      trigger.name = "Destroy CA public key in /vagrant folder"
      trigger.info = "Destroy CA public key in /vagrant folder"
      trigger.run = {inline: "rm ./trusted-user-ca-keys.pem "}
    end
  end

  config.vm.define "ubuntu_ssh" do |ubuntu_ssh|
    ubuntu_ssh.vm.hostname = "ubuntu-ssh-server"
    ubuntu_ssh.vm.box = "martinhristov90/ubuntu1604"
    ubuntu_ssh.vm.provision "shell", path: "./configs/scripts/ubuntuSSHsetup.sh", privileged: false
  end
end
  