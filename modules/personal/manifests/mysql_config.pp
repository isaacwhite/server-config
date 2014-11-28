class personal::mysql_config {

	include $personal::params

	class { '::mysql::server':
	  root_password    => $personal::params::mysql_root,
	}

	class {'::mysql::bindings':
		php_enable => true,
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
