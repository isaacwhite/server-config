class personal::mysql_config {

	include $personal::params

	# bugfix for mysql install acting weird.
    $rhel_mysql = 'http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'
	$indicator_file = '/.mysql-community-release'
    exec { 'mysql-community-repo':
      command => "/usr/bin/yum -y --nogpgcheck install '${rhel_mysql}' && touch ${indicator_file}",
      creates => $indicator_file,
    }

	class { '::mysql::server':
	  root_password    => $personal::params::mysql_root,
	  package_name => 'mysql-community-server',
	  require => Exec['mysql-community-repo'],
	}

	class {'::mysql::bindings':
		php_enable => true,
		notify => Service['php-fpm'],
	}

	class { 'mysql::client':
       package_name => 'mysql-community-client',
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
