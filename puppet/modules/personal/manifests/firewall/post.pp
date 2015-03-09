class personal::firewall::post {

	# deny any other traffic
	firewall { '999 deny all others':
		proto => 'all',
		action => "reject",
	}
}