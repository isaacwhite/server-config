define personal::types::database (
		$name = $title,
		$user = $title,
		$password,
		$source,
		$path = '/var/www/dbs/'
) {

	include mysql

	if (".gz" in $source) {
		$import = regsubst($source, '.gz$', '')

		# extract the file to the source path
		personal::types::extraction { "${name} unzip":
			source=> $source,
			destination => $path,
			path => '/.',
		}

	} else {
		$import = $name
	}

	$import_path = "${path}${import}"

	mysql::db { $name:
	  user     => $user,
	  password => $password,
	  host     => 'localhost',
	  grant    => ['ALL'],
	  sql      => $import_path,
	  import_timeout => 900,
	}
}
