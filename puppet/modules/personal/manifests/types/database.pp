define personal::types::database (
		$db_name = $title,
		$user = $title,
		$password = undef,
		$source,
		$path = '/var/www/dbs/'
	) {

	include mysql

	if (".gz" in $source) {
		$import = regsubst($source, '.gz$', '')

		# extract the file to the source path
		personal::types::extraction { "${db_name} unzip":
			source=> $source,
			destination => $path,
			path => '/.',
		}

	} else {
		$import = $db_name
	}

	$import_path = "${path}${import}"

	mysql::db { $db_name:
	  user     => $user,
	  password => $password,
	  host     => 'localhost',
	  grant    => ['ALL'],
	  sql      => $import_path,
	  import_timeout => 900,
	}
}
