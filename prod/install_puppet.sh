#!/bin/bash

file="/puppet-configured"
if [ -f "$file" ]
then
	echo "Puppet already installed. Moving on..."
else
	rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
	yes | yum -y install puppet
	touch "$file"
fi
