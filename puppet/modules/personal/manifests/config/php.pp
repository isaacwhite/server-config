class personal::config::php {

	class {'php::fpm::daemon':
		subscribe => Package['php-mysql'],
	}

	php::ini { '/etc/php.ini':
		display_errors => 'On',
		memory_limit   => '256M',
	}

	# make sure the yum repo is added before trying
	# to install the specific php version
	class {'php::cli':
		ensure => 'latest',
	}

	php::fpm::conf { 'www':
		listen  => '127.0.0.1:9000',
		user    => 'nginx',
		# For the user to exist
		require => Package['nginx'],
	}

	php::module { [ 'pdo', 'mbstring' ]: }
}
