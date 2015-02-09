define personal::types::domain (
	$name = $title,
	$subdomains,
	$git,
	$database,
	$files,
	) {

	$web_root = '/var/www/'
	$domain_root = "${web_root}${title}"
	$public = "${domain_root}/public_html"

	$base_dirs = [$domain_root, $public]

	file { $base_dirs:
		ensure => directory,
	}
	
}