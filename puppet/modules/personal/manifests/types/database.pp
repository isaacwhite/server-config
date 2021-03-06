define personal::types::database (
		$db_name = $title,
		$user = $title,
		$password = undef,
		$source,
		$path = '/var/www/dbs/'
	) {

	if (".gz" in $source) {
		$import = regsubst($source, '.gz$', '')

		# don't do this too frequently for the same box
		# extract the file to the source path
		personal::types::extraction { "${db_name} unzip":
			source => "${path}${source}",
			destination => $path,
			filename => $import,
			path => '',
			should_trigger => Mysql::Db[$db_name],
			once => true,
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
