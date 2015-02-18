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

	ensure_resource('sshkey', 'github', {
		name => "github.com",
		ensure => present,
		key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==",
		type => 'ssh-rsa',
	})
	
	ensure_resource('sshkey', 'bitbucket', {
		name => "bitbucket.org",
		ensure => present,
		key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==",
		type => 'ssh-rsa',
	})

	ensure_resource('file', 'user ssh folder', {
		path => "/home/${user}/.ssh",
		ensure => directory,
	})

	ensure_resource('file', 'deployer public key', {
		path => "/home/${user}/.ssh/id_rsa.pub",
		source => "puppet:///modules/personal/provision_rsa.pub",
		owner => $user,
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
			Sshkey['github'],
			Sshkey['bitbucket'],
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