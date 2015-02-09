class personal::mysql_config {

	$private = hiera('access')
	$password = $private['mysql_admin']['password']

	class { '::mysql::server':
		root_password    => $password,
		package_ensure => 'latest',
		require => Exec['mysql-community-repo'],
	}

	class {'::mysql::bindings':
		php_enable => true,
	}

	class { 'mysql::client':
	   package_name => 'mysql-community-client',
	   package_ensure => 'latest',
	   require => Exec['mysql-community-repo'],
   }
}
