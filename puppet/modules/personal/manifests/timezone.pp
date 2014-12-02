class personal::timezone {

	# make sure to sync with time servers
	include '::ntp'

	# set the timezone to EST
	file {'/etc/localtime':
		ensure => link,
		target => '/usr/share/zoneinfo/America/New_York',
	}
}
