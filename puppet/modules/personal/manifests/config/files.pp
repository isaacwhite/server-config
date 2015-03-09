class personal::config::files {

	# require all aws file downloads before file extraction
	Personal::Types::Sync <| |> -> Personal::Types::Extraction <| |>

	# pull config out of hiera
	$syncs = hiera_hash('aws')

	if ($syncs) {
		create_resources(personal::types::sync, $syncs)
	}

	# we should also condsider setting up the backup script here at some point
	
}
