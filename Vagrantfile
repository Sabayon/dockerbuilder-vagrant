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
  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /usr/portage/licenses/
    rsync -av -H -A -X --delete-during "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/"
    ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept

    equo up && sudo equo u
    echo -5 | equo conf update
    equo i docker vixie-cron git wget curl net-analyzer/netcat6 git-lfs e2fsprogs sys-fs/xfsprogs
    git lfs install

    systemctl enable docker
    systemctl start docker
    cp -rfv /vagrant/build.service /etc/systemd/system/
    cp -rfv /vagrant/setup.sh /opt/setup.sh
    systemctl daemon-reload
    systemctl enable build
    systemctl start build
    systemctl enable vixie-cron
    systemctl start vixie-cron
    crontab /vagrant/crontab
    echo "@@@@ Do docker login if necessary."
  SHELL
end
