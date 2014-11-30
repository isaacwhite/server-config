class personal::firewall_config {

	include firewall

	firewall { '100 allow sshd':
		state => ['NEW'],
		dport => '22',
		proto => 'tcp',
		action  => 'accept',
	}

	firewall { '100 allow nginx:80':
		state => ['NEW'],
		dport => '80',
		proto => 'tcp',
		action  => 'accept',
	}

	firewall { '999 deny all others':
		action => "drop",
	}
}
