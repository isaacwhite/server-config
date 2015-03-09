class personal::params {
	
	# provide a user based on environment
	$username = $vm_environment ? {	
		'staging' => 'isaac',
		'production' => 'isaac',
		default =>'vagrant',
	}

	# local dev environment is symlinked. 
	# Will error if user/group does not exist on host
	if $vm_environment != 'sandbox' {
		$owner = 'isaac'
		$group = 'nginx'
	} else {
		$owner = undef
		$group = undef
	}

}
