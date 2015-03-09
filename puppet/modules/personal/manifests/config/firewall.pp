class personal::config::firewall {

	include firewall
	include personal::firewall::post

	if $vm_environment != 'sandbox' {
		resources { 'firewall': 
			purge => true,
		}
	}

	class {'personal::firewall::pre':
		before => Class['personal::firewall::post'],
	}
}
