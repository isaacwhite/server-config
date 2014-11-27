class personal::timezone {

	# set the timezone to EST
	file {'/etc/localtime':
		ensure => link,
		target => '/usr/share/zoneinfo/America/New_York',
	}
}
