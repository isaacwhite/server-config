#main class
class {'personal':}

# suppress an annoying warning. ugh.
Package {
	allow_virtual => false
}

# pull out hiera to test
# $hiera_stuff = hiera('sample_value')

# notify {$hiera_stuff: }
