# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_NAME = 'LAMP'

HOST_PATH = Dir.pwd

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "testlamp"

  config.vm.provider "virtualbox" do |v|
    v.name = VM_NAME
    v.memory = 2048
  end

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 22, host: 2222, auto_correct: true
  config.vm.network "forwarded_port", guest: 3306, host: 3306, auto_correct: true
  config.vm.network "public_network"

  config.vm.synced_folder HOST_PATH+"/www", "/var/www/", type: "rsync"

  config.vm.provision "shell", path: "boot.sh"
end
