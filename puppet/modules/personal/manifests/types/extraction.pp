define personal::types::extraction (
		$source = $title,
		$destination,
		$path = "/sites/default",
		$filename = '',
		$should_trigger = undef,
	) {

	$output_dir = "${destination}${path}"

	ensure_resource('file', $output_dir, {
		ensure => directory,
		# mode => '775',
		# owner => $personal::params::username,
		# group => 'nginx',
	})

	# allow both gzip and tar.gz
	# grep 
	if ("tar.gz" in $source) {
		exec {"tar --no-same-owner -xf ${source} -C ${output_dir}":
			path => '/bin',
			require => [
				Package['tar'],
				File[$output_dir],
			],
			notify => $should_trigger,
		}
	} 

	elsif (".gz" in $source) {
		$extract_to = "${output_dir}${filename}"
		exec {"gunzip -c ${source} > ${extract_to}":
			path => '/usr/bin',
			require => [
				Package['gzip'],
				File[$output_dir],
			],
			notify => $should_trigger,
		}
	}
}