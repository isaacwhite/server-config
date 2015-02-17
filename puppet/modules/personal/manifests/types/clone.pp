define personal::types::clone (
		$repo = $title,
		$branch = 'master',
		$path,
	) {

	if $fqdn == 'GLaDOS-local' {
		$gituser = 'vagrant'
	} else {
		$gituser = 'isaac'
	}

	ensure_resource('file', 'user ssh folder', {
		path => "/home/${gituser}/.ssh",
		ensure => directory,
	})

	ensure_resource('file', 'deployer public key', {
		path => "/home/${gituser}/.ssh/id_rsa.pub",
		source => "puppet:///modules/personal/provision_rsa.pub",
	})

	ensure_resource('file', 'deployer private key', {
		path => "/home/${gituser}/.ssh/id_rsa",
		source => "puppet:///modules/personal/provision_rsa",
	})

	exec {"${title}: git clone into ${path}":
		command => "git clone ${repo} ${path}",
		creates => "${path}/.git",
		path => '/usr/bin',
		require => [
			Package['git'],
			File['deployer private key'],
			File['deployer public key'],
		],
		user => $gituser,
	}

	exec {"${title}: git checkout ${branch} @ ${path}":
		command => "git checkout ${branch}",
		onlyif => "test \"git rev-parse --abbrev-ref HEAD\" != \"${branch}\"",
		path => '/user/bin',
		require => [
			Package['git'],
			File['deployer private key'],
			File['deployer public key'],
		],
		user => $gituser,
		cwd => $path,
	}
}