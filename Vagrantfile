# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.define "sbx", primary: true do |sbx|
    sbx.vm.box = "puppetlabs/centos-6.5-64-puppet"
    sbx.vm.hostname = "GLaDOS-local"
  	sbx.hostsupdater.aliases = [
  		"sbx.isaacwhite.com",
  		"www.sbx.isaacwhite.com",
  		"sbx.mytimes.isaacwhite.com",
  		"sbx.scylla.isaacwhite.com",
  		"sbx.joshuarobertwhite.com",
  		"www.sbx.joshuarobertwhite.com",
  		"sbx.dev.joshuarobertwhite.com",
  		"sbx.solomonhoffman.com",
  		"www.sbx.solomonhoffman.com",
  		"sbx.dev.solomonhoffman.com",
      "sbx.karakrakower.com",
      "sbx.dev.karakrakower.com",
      "www.sbx.karakrakower.com",
      "bogus.sbx.isaacwhite.com",
      "bogus.sbx.karakrakower.com",
      "bogus.sbx.joshuarobertwhite.com",
      "bogus.sbx.solomonhoffman.com"
  	]

    sbx.vm.network :forwarded_port, guest: 443, host: 8443
    sbx.vm.network :forwarded_port, guest: 8888, host: 8888

    sbx.vm.network :private_network, ip: "192.168.10.15"

    # If true, then any SSH connections made will enable agent forwarding.
    # Default value: false
    sbx.ssh.forward_agent = true

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    sbx.vm.synced_folder "~/workspace", "/var/www", :create => true, :nfs => true
    sbx.vm.synced_folder "puppet", "/puppet", :create => true, :nfs => true

    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    # Example for VirtualBox:
    #
    # View the documentation for the provider you're using for more
    # information on available options.
    sbx.vm.provider :virtualbox do |vb|
      # Don't boot with headless mode
      vb.gui = false
      vb.name = 'GLaDOS Local v2'

      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    
    sbx.vm.provision :puppet, :options => "--verbose", :module_path => "modules" do |puppet|
      puppet.options = "--hiera_config /puppet/hiera.yaml --parser=future"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "init.pp"
      puppet.facter = {
        "vm_environment" => "sandbox"
      }
    end

  end

  config.vm.define "stg", autostart: false do |stg|
    stg.vm.box = "digital_ocean"
    stg.vm.hostname = "GLaDOS-centos-stg"

    
    stg.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = '~/.ssh/id_rsa'
      override.vm.box = "digital_ocean"
      # override.ssh.username = "root"
      # override.ssh.password = ENV['PROVISION_PASS']

      provider.client_id = "vagrant"
      provider.api_key = ENV['DIGITAL_OCEAN_KEY']
      provider.image = "centos-6-5-x64"
      provider.region = "nyc3"
      provider.token = ENV['DIGITAL_OCEAN_KEY']
      provider.size ="2gb"
    end

    stg.vm.provision :shell, :path => 'install_puppet.sh'
    stg.vm.synced_folder "puppet", "/puppet", :create => true, :nfs => true
 
    stg.vm.provision :puppet, :options => "--verbose", :module_path => "modules" do |puppet|
      puppet.options = "--hiera_config /puppet/hiera.yaml --parser=future"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "init.pp"
      puppet.facter = {
        "vm_environment" => "staging"
      }
    end
  end

  config.vm.define "prod", autostart: false do |prod, override|

    prod.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = '~/.ssh/id_rsa'
      override.vm.hostname = "GLaDOS-centos-test"
      override.vm.box = "digital_ocean"
      override.ssh.forward_agent = true
      
      provider.client_id = "vagrant"
      provider.api_key = ENV['DIGITAL_OCEAN_KEY']
      provider.image = "6.5 x64"
      provider.region = "nyc3"
      provider.token = ENV['DIGITAL_OCEAN_KEY']
      provider.size ="2gb"
    end

    prod.vm.provision :shell, :path => 'install_puppet.sh'
    prod.vm.synced_folder "puppet", "/puppet", :create => true, :nfs => true

    prod.vm.provision :puppet, :options => "--verbose", :module_path => "modules" do |puppet|
      puppet.options = "--hiera_config /puppet/manifests/hiera.yaml --parser=future"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "init.pp"
      puppet.facter = {
        "vm_environment" => "production"
      }
    end

  end

end
