class personal::packages {

	# PHP Packages
	#some repos, make sure we can get the right version of php
	class {'::yum::repo::remi':}
	class {'::yum::repo::remi_php55':}

	# =======================
	# MySQL repos
	# bugfix for mysql install acting weird.
	$rhel_mysql = 'http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'
	$indicator_file = '/.mysql-community-release'
	$mysql_ver = 'latest'

	exec { 'mysql-community-repo':
	  command => "/usr/bin/yum -y --nogpgcheck install '${rhel_mysql}' && touch ${indicator_file}",
	  creates => $indicator_file,
	}

	# mysql v5.6 seems to have issues,
	# delete the repo and allow puppet to install latest via v5.5
	yumrepo {'mysql56-community':
		ensure => absent,
	}

	yumrepo {'mysql55-community':
		enabled => true,
	}

	# =======================
	# AWS
	package {'python-pip':
		ensure => present,

	}

	package {'awscli':
		ensure => present,
		provider => pip,
		require => Package['python-pip'],
	}

	package {'gzip':
		ensure => present,
	}

	package {'tar':
		ensure => present,
	}
}