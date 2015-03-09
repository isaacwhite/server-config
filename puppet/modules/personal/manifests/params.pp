class personal::params {
	
	# provide a user based on environment
	$username = $vm_environment ? {	
		'staging' => 'isaac',
		'production' => 'isaac',
		default =>'vagrant',
	}

}
