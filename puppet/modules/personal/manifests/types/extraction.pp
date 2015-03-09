define personal::types::extraction (
		$source = $title,
		$destination,
		$path = "/sites/default",
		$filename = '',
		$should_trigger = undef,
		$once = false,
	) {

	$output_dir = "${destination}${path}"

	ensure_resource('file', $output_dir, {
		ensure => directory,
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
		$indicator = "${output_dir}${filename}_extracted"

		exec {"extract ${extract_to}":
			command => "gunzip -c ${source} > ${extract_to}",
			path => '/usr/bin',
			require => [
				Package['gzip'],
				File[$output_dir],
			],
			notify => $should_trigger,
			unless => "/usr/bin/test -f ${indicator}",
		}

		if $once {
			exec {"touch $indicator":
				path => '/bin',
				require => Exec["extract ${extract_to}"],
				creates => $indicator,
			}
		}

	}
}