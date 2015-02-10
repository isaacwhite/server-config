define personal::types::database (
		$name,
		$source
) {

	include mysql

	mysql::db { $database:
	  user     => $database,
	  password => $password,
	  host     => 'localhost',
	  grant    => ['ALL'],
	  sql      => $path,
	  import_timeout => 900,
	}
}
