define personal::types::clone (
		$remote = $title,
		$branch = 'master',
		$path,
	) {

	if $fqdn == 'GLaDOS-local' {
		$user = 'vagrant'
	} else {
		$user = 'isaac'
	}

	

	ensure_resource('file', 'user ssh folder', {
		path => "/home/${user}/.ssh",
		ensure => directory,
	})

	ensure_resource('file', 'deployer public key', {
		path => "/home/${user}/.ssh/id_rsa.pub",
		source => "puppet:///modules/personal/provision_rsa.pub",
		owner => $user,
	})

	ensure_resource('file', 'known hosts', {
		path => "/home/$user/.ssh/known_hosts",
		source => "puppet:///modules/personal/known_hosts",
		owner => $user,
		mode => '0644',
	})

	ensure_resource('file', 'deployer private key', {
		path => "/home/${user}/.ssh/id_rsa",
		source => "puppet:///modules/personal/provision_rsa",
		owner => $user,
	})

	exec {"git clone ${path}":
		command => "git clone ${remote} ${path}",
		onlyif => "test ! -d ${path}/.git",
		path => '/usr/bin',
		require => [
			Package['git'],
			File['deployer private key'],
			File['deployer public key'],
			File['known hosts']
		],
		user => $user,
	}

	exec {"$ git checkout ${branch} ${path}":
		command => "git checkout ${branch}",
		onlyif => "test \"git rev-parse --abbrev-ref HEAD\" != \"${branch}\"",
		path => '/usr/bin',
		require => [
			Package['git'],
			File['deployer private key'],
			File['deployer public key'],
			Exec["git clone ${path}"],
		],
		user => $user,
		cwd => $path,
	}
}