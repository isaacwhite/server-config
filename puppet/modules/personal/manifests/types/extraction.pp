define personal::types::extraction (
		$root,
		$path = "/sites/default",
	) {

	# allow both gzip and tar.gz
	# grep 
	if ($which == 'gzip') {
		exec {"gunzip -c ${source} > ${destination}":
			path => '/usr/bin',
			require => Package['gzip'],
		}
	} else {
		exec {"tar -xfz ${source} -C ${destination}":
			path => '/usr/bin',
			require => Package['tar'],
		}
	}
}