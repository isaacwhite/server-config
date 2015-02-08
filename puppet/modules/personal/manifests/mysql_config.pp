class personal::mysql_config {

	include $personal::params

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
		$unzip = false,
	) {
		# if our database requires unzipping, do that first.
		if $unzip {
			exec {"gunzip -f ${path}.gz":
				logoutput => true,
				path => '/usr/bin',
			}
		}

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
