define personal::types::clone (
		$remote = $title,
		$branch = 'master',
		$path,
	) {

	$username = $personal::params::username

	ensure_resource('file', 'user ssh folder', {
		path => "/home/${username}/.ssh",
		ensure => directory,
	})

	ensure_resource('file', 'deployer public key', {
		path => "/home/${username}/.ssh/id_rsa.pub",
		source => "puppet:///modules/personal/provision_rsa.pub",
		owner => $username,
	})

	ensure_resource('file', 'known hosts', {
		path => "/home/${username}/.ssh/known_hosts",
		source => "puppet:///modules/personal/known_hosts",
		mode => '0644',
		owner => $username,
	})

	ensure_resource('file', 'deployer private key', {
		path => "/home/${username}/.ssh/id_rsa",
		source => "puppet:///modules/personal/provision_rsa",
		owner => $username,
	})

	exec {"git clone ${path}":
		command => "git clone ${remote} .",
		onlyif => "/usr/bin/test ! -d ${path}/.git",
		path => '/usr/bin',
		require => [
			Package['git'],
			File['deployer private key'],
			File['deployer public key'],
			File['known hosts']
		],
		user => $username,
		cwd => $path,
	}

	exec {"git checkout ${branch} ${path}":
		command => "git checkout ${branch}",
		unless => "/usr/bin/git rev-parse --abbrev-ref HEAD | /bin/grep -q ${branch}",
		path => '/usr/bin',
		require => [
			Package['git'],
			File['deployer private key'],
			File['deployer public key'],
			Exec["git clone ${path}"],
		],
		user => $username,
		cwd => $path,
	}
}