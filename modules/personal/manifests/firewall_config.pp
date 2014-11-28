class personal::firewall_config {

	include firewall

	firewall { '100 allow ssh':
		state => ['NEW'],
		dport => '22',
		proto => 'tcp',
		action  => 'accept',
	}

	firewall { '100 allow httpd:80':
		state => ['NEW'],
		dport => '80',
		proto => 'tcp',
		action  => 'accept',
	}
}
