define personal::types::extraction (
		$source = $name,
		$destination,
	) {

	# allow both gzip and tar.gz
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