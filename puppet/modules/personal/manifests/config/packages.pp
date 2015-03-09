class personal::config::packages {

	# make sure all repos are updated before packages everywhere.
	Yumrepo <| |> -> Package <| |>

	# support items like python pip
	include epel
	#some repos, make sure we can get the right version of php
	$remi_gpg_key = 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'

	yumrepo { 'remi-php55':
	    mirrorlist     => 'http://rpms.famillecollet.com/enterprise/6/php55/mirror',
	    gpgkey         => $remi_gpg_key,
	    gpgcheck  	   => 1,
	    enabled        => 1,
	    priority => 1,
	}

	yumrepo { 'remi':
	    mirrorlist     => 'http://rpms.famillecollet.com/enterprise/6/remi/mirror',
	    gpgkey         => $remi_gpg_key,
	    gpgcheck  	   => 1,
	    enabled        => 1,
	    priority       => 1,
	}

    yumrepo { 'remi-test':
		mirrorlist     => 'http://rpms.famillecollet.com/enterprise/6/test/mirror',
		gpgkey         => $remi_gpg_key,
	    gpgcheck  	   => 1,
		enabled        => 0,
		priority       => 1,
	}

	# =======================
	# MySQL repos
	# bugfix for mysql install acting weird.
	$rhel_mysql = 'http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'
	$indicator_file = '/.mysql-community-release'

	exec { 'mysql-community-repo':
	  command => "/usr/bin/yum -y --nogpgcheck install '${rhel_mysql}' && touch ${indicator_file}",
	  creates => $indicator_file,
	}

	# mysql v5.6 seems to have issues,
	# delete the repo and allow puppet to install latest via v5.5
	yumrepo { 'mysql56-community':
		ensure => absent,
	}

	yumrepo { 'mysql55-community':
		enabled => true,
	}

	# make sure we have the repo for recent nginx releases
	yumrepo {'nginx-release':
      baseurl  => "http://nginx.org/packages/rhel/6/x86_64/",
      descr    => 'nginx repo',
      enabled  => '1',
      gpgcheck => '1',
      priority => '1',
      gpgkey   => 'http://nginx.org/keys/nginx_signing.key',
    }

    file { '/etc/yum.repos.d/nginx-release.repo':
      ensure  => present,
      require => Yumrepo['nginx-release'],
    }

	$present_packages = [
		# aws dep
		'python-setuptools',
		# zsh dep
		'git',
		'zsh',
		#  extraction dep
		'gzip',
		'tar',
		# drush dep
		'php-pear',
		# nginx
		'nginx',
		# etc
		'openssl',
		'libpng',
		'vim-enhanced',
	]


	package { $present_packages:
		ensure => present,
	}

	package {'python-pip':
		ensure => present,
		require => Package['python-setuptools'],
	}

	package { 'awscli':
		ensure => present,
		provider => pip,
		require => Package['python-pip'],
	}

	package {'php-gd':
		ensure => present,
		require => [
			Package['php-common'],
			Package['libpng'],
		],
	}
}