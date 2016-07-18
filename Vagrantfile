# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
vagrantfile_api_version = "2"

# definitions for the machines provisioned by this vagrant file
box_params = {
  box: 'erumble/centos7-x64',
  hostname: 'docker.dev',
  ip: '192.168.5.31',
  playbook: 'ansible/playbook.yml'
}

# make the vagrant machine(s)
Vagrant.configure(vagrantfile_api_version) do |config|
  config.vm.define box_params.fetch(:hostname) do |box|

    # specify the box, hostname, and ip address
    box.vm.box = box_params.fetch :box
    box.vm.hostname = box_params.fetch :hostname
    box.vm.network :private_network, ip: box_params.fetch(:ip)

    # configure /etc/hosts on the host os if the given plugin is installed
    box.hostsupdater.aliases = box_params[:hostname_aliases] if Vagrant.has_plugin? 'vagrant-hostsupdater'

    # explicitly set hostname, because reasons
    box.vm.provision :shell, inline: "hostnamectl set-hostname #{box_params[:hostname]}" if box.vm.box == 'erumble/centos71-x64'

    # forward the ssh agent for things like git
    box.ssh.forward_agent = true

    # provision the thing
    box.vm.provision :ansible do |ansible|
      ansible.playbook = box_params.fetch :playbook
    end

  end # config.vm.define
end # Vagrant.configure
