define personal::types::extraction (
		$source = $title,
		$destination,
		$path = "/sites/default",
	) {

	$ouput_dir = "${destionation}${path}"
	# allow both gzip and tar.gz
	# grep 
	if ("tar.gz" in $source) {
		exec {"gunzip -c ${source} > ${output_dir}":
			path => '/usr/bin',
			require => Package['gzip'],
		}
	} 

	elsif (".gz" in $source) {
		exec {"tar -xfz ${source} -C ${output_dir}":
			path => '/usr/bin',
			require => Package['tar'],
		}
	}
}