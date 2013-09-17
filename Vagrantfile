# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Use this Vagrantfile to standup the Baribican network
#

Vagrant.configure("2") do |config|

  config.vm.box = "opscode-centos-6.4"
  #config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"

  # Note: The host machine looks like '10.0.2.2' to this private network!

  config.vm.define :barbican_api do |barbican_api|
    barbican_api.vm.hostname = "barbican-api-test"

    # Forward guest port 9311 to host port 9311. If changed, run 'vagrant reload'.
    barbican_api.vm.network :private_network, ip: "192.168.50.4", :netmask => "255.255.0.0"
    barbican_api.vm.network :forwarded_port, guest: 9311, host: 9311
    barbican_api.vm.network :forwarded_port, guest: 9312, host: 9312
    barbican_api.vm.network :forwarded_port, guest: 22, host: 2204, auto_correct: true
    barbican_api.vm.network :forwarded_port, guest: 80, host: 8004

    # Provision the node.
    barbican_api.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.run_list = [
        "role[base]",
        "role[api]",
        "recipe[barbican-api]",
      ]
    end
  end

  config.vm.define :barbican_worker do |barbican_worker|
    barbican_worker.vm.hostname = "barbican-worker-test"

    barbican_worker.vm.network :private_network, ip: "192.168.50.6", :netmask => "255.255.0.0"
    barbican_worker.vm.network :forwarded_port, guest: 22, host: 2206, auto_correct: true
    barbican_worker.vm.network :forwarded_port, guest: 80, host: 8006

    # Forward guest port 9311 to host port 9311. If changed, run 'vagrant reload'.
    # barbican_worker.vm.network :forwarded_port, guest: 9311, host: 9311

    # Provision the node.
    barbican_worker.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.run_list = [
        "role[base]",
        "role[worker]",
        "recipe[barbican-worker]",
      ]
    end
  end

  config.vm.define :barbican_queue do |barbican_queue|
    barbican_queue.vm.hostname = "barbican-queue-test"

    barbican_queue.vm.network :private_network, ip: "192.168.50.8", :netmask => "255.255.0.0"
    barbican_queue.vm.network :forwarded_port, guest: 22, host: 2208, auto_correct: true
    barbican_queue.vm.network :forwarded_port, guest: 80, host: 8008

    # Forward guest port 9311 to host port 9311. If changed, run 'vagrant reload'.
    #barbican_queue.vm.network :forwarded_port, guest: 9311, host: 9311
    #barbican_queue.vm.network :forwarded_port, guest: 9312, host: 9312

    # Provision the node.
    barbican_queue.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.run_list = [
        "role[base]",
        "role[queue]",
        "recipe[barbican-queue]",
      ]
    end
  end

  config.vm.define :dbsimple do |dbsimple|
    dbsimple.vm.hostname = "db-simple"
    dbsimple.vm.network :private_network, ip: "192.168.50.17", :netmask => "255.255.0.0"
    dbsimple.vm.network :forwarded_port, guest: 22, host: 2217, auto_correct: true
    dbsimple.vm.network :forwarded_port, guest: 5432, host: 5432
    dbsimple.vm.network :forwarded_port, guest: 80, host: 8017
    dbsimple.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.json = {
                    "postgresql" => {
                        "password" => {
                            "postgres" => "mypass"
                        },
                        'enable_pgdg_yum' => true,
                        "version" => "9.2",
                        'dir' => "/var/lib/pgsql/9.2/data",
                        'server' => {
                            'packages' => ["postgresql92-server"],
                            'service_name' => "postgresql-9.2"
                        },
                        'contrib' => {
                            'packages' => ["postgresql92-contrib"]
                        },
                        'config' => {
                            'listen_addresses' => '*'
                        },
                        'pg_hba' => [
                          {
                            'comment' => '# "local" is for Unix domain socket connections only',
                            'type' => 'local', 
                            'db' => 'all',
                            'user' => 'postgres', 
                            'addr' => nil,
                            'method' => 'ident'
                          },
                          {
                            'type' => 'local', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => nil,
                            'method' => 'ident'
                          },
                          {
                            'comment' => '# Open external comms with database',
                            'type' => 'host', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => '10.0.2.2/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open comms with the api node',
                            'type' => 'host', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => '192.168.50.4/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open comms with the worker node',
                            'type' => 'host', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => '192.168.50.6/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open localhost comms with database',
                            'type' => 'host', 
                            'db' => 'all',
			    'user' => 'all', 
                            'addr' => '127.0.0.1/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open IPv6 localhost comms with database',
                            'type' => 'host', 
                            'db' => 'all',
			    'user' => 'all', 
                            'addr' => '::1/128',
                            'method' => 'md5'
                          }
                        ]
                    }
                  }
      chef.run_list = [
        #"role[base]",
        "recipe[postgresql]",
        "recipe[postgresql::server]",
        "recipe[database::postgresql]",
        "recipe[database]",
        "recipe[barbican-db]"
        #"recipe[chef-cloudpassage]"
      ]
    end
  end

  config.vm.define :dbmaster do |dbmaster|
    dbmaster.vm.hostname = "db-master"
    dbmaster.vm.network :private_network, ip: "10.0.2.17"
    dbmaster.vm.network :forwarded_port, guest: 22, host: 1236, auto_correct: true
    dbmaster.vm.network :forwarded_port, guest: 5432, host: 5437
    dbmaster.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.json = {
                    "postgresql" => {
                        "password" => {
                            "postgres" => "55305adaac499dbbc6865a44e4aa5d8b4"
                        },
                        'enable_pgdg_yum' => true,
                        "version" => "9.2",
                        'dir' => "/var/lib/pgsql/9.2/data",
                        'server' => {
                            'packages' => ["postgresql92-server"],
                            'service_name' => "postgresql-9.2"
                        },
                        'contrib' => {
                            'packages' => ["postgresql92-contrib"]
                        },
                        'config' => {
                            'listen_addresses' => '*'
                        },
                        'max_wal_senders' => 0, 
                        'wal_sender_delay' => '1s',
                        'wal_keep_segments' => 0,   
                        'vacuum_defer_cleanup_age' => 0,
                        'replication_timeout' => '60s',
                        'synchronous_standby_names' => '',

                        'pg_hba' => [
                          {
                            'comment' => '# "local" is for Unix domain socket connections only',
                            'type' => 'local', 
                            'db' => 'all',
                            'user' => 'postgres', 
                            'addr' => nil,
                            'method' => 'ident'
                          },
                          {
                            'type' => 'local', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => nil,
                            'method' => 'ident'
                          },
                          {
                            'comment' => '# Open external comms with database',
                            'type' => 'host', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => '10.0.2.2/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open localhost comms with database',
                            'type' => 'host', 
                            'db' => 'all',
			    'user' => 'all', 
                            'addr' => '127.0.0.1/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open IPv6 localhost comms with database',
                            'type' => 'host', 
                            'db' => 'all',
			    'user' => 'all', 
                            'addr' => '::1/128',
                            'method' => 'md5'
                          }
                        ]
                    }
                  }
      chef.run_list = [
        #"role[base]",
        "recipe[postgresql]",
        "recipe[postgresql::server]",
        "recipe[database::postgresql]",
        "recipe[database]",
        "recipe[barbican-db]"
        #"recipe[chef-cloudpassage]"
      ]
    end
  end

  config.vm.define :dbslave do |dbslave|
    dbslave.vm.hostname = "db-slave"
    dbslave.vm.network :private_network, ip: "10.0.2.18"
    dbslave.vm.network :forwarded_port, guest: 22, host: 1238, auto_correct: true
    dbslave.vm.network :forwarded_port, guest: 5432, host: 5439
    dbslave.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.json = {
                    "postgresql" => {
                        "password" => {
                            "postgres" => "55305adaac499dbbc6865a44e4aa5d8b4"
                        },
                        'enable_pgdg_yum' => true,
                        "version" => "9.2",
                        'dir' => "/var/lib/pgsql/9.2/data",
                        'server' => {
                            'packages' => ["postgresql92-server"],
                            'service_name' => "postgresql-9.2"
                        },
                        'contrib' => {
                            'packages' => ["postgresql92-contrib"]
                        },
                        'config' => {
                            'listen_addresses' => '*'
                        },
                        'hot_standby' => 'off',
                        'max_standby_archive_delay' => '30s',
                        'max_standby_streaming_delay' => '30s',
                        'wal_receiver_status_interval' => '10s',
                        'hot_standby_feedback' => 'off',
                        'pg_hba' => [
                          {
                            'comment' => '# "local" is for Unix domain socket connections only',
                            'type' => 'local', 
                            'db' => 'all',
                            'user' => 'postgres', 
                            'addr' => nil,
                            'method' => 'ident'
                          },
                          {
                            'type' => 'local', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => nil,
                            'method' => 'ident'
                          },
                          {
                            'comment' => '# Master database IP',
                            'type' => 'host', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => '10.0.2.17/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open external comms with database',
                            'type' => 'host', 
                            'db' => 'all',
                            'user' => 'all', 
                            'addr' => '10.0.2.2/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open localhost comms with database',
                            'type' => 'host', 
                            'db' => 'all',
			    'user' => 'all', 
                            'addr' => '127.0.0.1/32',
                            'method' => 'trust'
                          },
                          {
                            'comment' => '# Open IPv6 localhost comms with database',
                            'type' => 'host', 
                            'db' => 'all',
			    'user' => 'all', 
                            'addr' => '::1/128',
                            'method' => 'md5'
                          }
                        ]
                    }
                  }
      chef.run_list = [
        #"role[base]",
        "recipe[postgresql]",
        "recipe[postgresql::server]",
        "recipe[database::postgresql]",
        "recipe[database]",
        "recipe[barbican-db]"
        #"recipe[chef-cloudpassage]"
      ]
    end
  end

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

end
