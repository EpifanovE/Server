Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.provider :virtualbox do |vb|
    vb.name = "DevServer"
  end

  config.vm.hostname = "devserver"

  config.vm.box_check_update = true

  config.vm.network "forwarded_port", guest: 80, host: 8070

  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.vm.network "forwarded_port", guest: 22, host: 2222, host_ip: "127.0.0.1", id: 'ssh'

  config.vm.network "private_network", ip: "192.168.10.10"

  config.vm.network "public_network", ip: "192.168.10.11"

  config.vm.synced_folder ".", "/home/vagrant/server"

  config.vm.synced_folder "../ocms", "/home/vagrant/code/ocms"

  config.vm.provision :shell, :path => "./scripts/install.sh"

end
