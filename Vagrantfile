VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.host_name = "federated-openstack"

  config.vm.box = "hashicorp/precise64"

  config.vm.network :forwarded_port, guest: 80, host: 20000

  config.vm.provision :shell, :path => "bootstrap.sh"

  config.vm.provider :virtualbox do |vb|
    vb.name = "Federated OpenStack"
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
end
