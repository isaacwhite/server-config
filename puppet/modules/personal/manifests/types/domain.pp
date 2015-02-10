define personal::types::domain (	
	$name = $title,
	$subdomains,
	$git,
	$database,
	$files
	) {
	include personal::types::site

	$web_root = '/var/www/'
	
	file { "${web_root}${name}":
		ensure => directory,
	}

	site { $name:
		git => $git,
		database => $database,
		files => $files,
	}

	
	
}