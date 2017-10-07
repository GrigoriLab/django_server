# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.define "djangoserver" do |djangoserver|
		djangoserver.vm.box = "ubuntu/trusty32"
		djangoserver.vm.hostname = "djServer"
		djangoserver.vm.network "public_network"
		djangoserver.vm.synced_folder '.', '/home/vagrant/sharedFolder'
		djangoserver.vm.provision :shell do |s|
			s.path = 'bootstrap.sh'
		end
	end
end
