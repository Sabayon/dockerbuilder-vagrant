# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.box = "Sabayon/spinbase-amd64"
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
     vb.cpus = 1
  end

  config.vm.synced_folder "artifacts", "/artifacts_dir", create: true
  config.vm.synced_folder "logs", "/logs_dir", create: true
  config.vm.provision "shell", path: "scripts/provision.sh"
end
