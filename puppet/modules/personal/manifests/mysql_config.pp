class personal::mysql_config {

	include $personal::params

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

	class { '::mysql::server':
		root_password    => $personal::params::mysql_root,
		package_ensure => $mysql_ver,
		require => Exec['mysql-community-repo'],
	}

	class {'::mysql::bindings':
		php_enable => true,
	}

	class { 'mysql::client':
	   package_name => 'mysql-community-client',
	   package_ensure => $mysql_ver,
	   require => Exec['mysql-community-repo'],
   }

	create_resources(mysql_db, $personal::params::dbs)

	define mysql_db (
		$database = $title,
		$path,
	) {
		mysql::db { $database:
		  user     => $database,
		  password => 'password',
		  host     => 'localhost',
		  grant    => ['ALL'],
		  sql      => $path,
		  import_timeout => 900,
		}
	}
}
