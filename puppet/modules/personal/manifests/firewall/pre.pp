class personal::firewall::pre {

	firewall {'000 accept all icmp requests':
		proto => 'icmp',
		action => 'accept',
	}->

	firewall { '001 accept all to lo interface':
		proto => 'all',
		iniface => 'lo',
		action => 'accept'
	} ->

	firewall { '003 accept related established rules':
		proto   => 'all',
		state => ['RELATED', 'ESTABLISHED'],
		action  => 'accept',
	} ->

	firewall { '100 allow sshd':
		state => ['NEW'],
		port => 22,
		proto => 'tcp',
		action  => 'accept',
	} ->

	firewall { '100 allow nginx':
		state => ['NEW'],
		port => [80, 443],
		proto => 'tcp',
		action  => 'accept',
	}

}