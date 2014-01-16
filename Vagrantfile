# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # A box to build off of:
  config.vm.box = "quantal64"
  
  # Provision scripts common for all virtual machines:
  config.vm.provision :shell, :path => "configure.sh"
  config.vm.provision :shell, :path => "install-prerequisities.sh"
  config.vm.provision :shell, :path => "install-mq.sh"
  config.vm.provision :shell, :path => "add-users.sh"
  
  ###################################################################
  # Configuration for the mq001 queue manager's virtual machine.
  config.vm.define :mq001 do |qm|
    # IP address:
    qm.vm.network :private_network, ip: "192.168.56.101"
    
    # Hostname:
    qm.vm.hostname = "mq001"
    
    # Shell scripts for provisioning:
    qm.vm.provision :shell do |s|
        s.path  = "create-qm.sh"
    end
    
    # Port forwarfing for the standard MQ port:
    qm.vm.network :forwarded_port, guest: 1414, host: 2201
  end

  ###################################################################
  # Configuration for the mq002 queue manager's virtual machine.
  #config.vm.define :mq002 do |qm|
  #  # IP address:
  #  qm.vm.network :private_network, ip: "192.168.56.102"
  #
  #  # Hostname:
  #  qm.vm.hostname = "mq002"
  #  
  #  # Shell scripts for provisioning:
  #  qm.vm.provision :shell do |s|
  #      s.path  = "create-qm.sh"
  #  end
  #
  #  # Port forwarfing for the standard MQ port:
  #  qm.vm.network :forwarded_port, guest: 1414, host: 2202
  #end

  ###################################################################
  # Mount shared resources:
  config.vm.synced_folder "./install", "/install"
  config.vm.synced_folder "./mqsc", "/install/mqsc"
  config.vm.synced_folder ".", "/home/vagrant"

  ###################################################################
  # Oracle VirtualBox specific settings:
  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode:
    # vb.gui = true
  
    # Change available RAM:
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

end
