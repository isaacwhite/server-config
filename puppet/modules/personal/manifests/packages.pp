class personal::packages {

	# make sure all repos are updated before packages everywhere.
	Yumrepo <| |> -> Package <| |>

	# PHP Packages
	#some repos, make sure we can get the right version of php
	# class {'::yum::repo::remi':}
	# class {'::yum::repo::remi_php55':}
	yumrepo { 'remi-php55':
	    descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 5.5',
	    mirrorlist     => 'http://rpms.famillecollet.com/enterprise/6/php55/mirror',
	    enabled        => 1,
	    priority => 1,
	}

	yumrepo { 'remi':
	    descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch',
	    mirrorlist     => 'http://rpms.famillecollet.com/enterprise/6/remi/mirror',
	    enabled        => 1,
	    priority       => 1,
	}

    yumrepo { 'remi-test':
		descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - Test',
		mirrorlist     => 'http://rpms.famillecollet.com/enterprise/6/test/mirror',
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

	$present_packages = [
		# aws dep
		'python-pip',
		# zsh dep
		'git',
		'zsh',
		#  extraction dep
		'gzip',
		'tar',
	]

	package { $present_packages:
		ensure => present,
	}

	package { 'awscli':
		ensure => present,
		provider => pip,
		require => Package['python-pip'],
	}
}