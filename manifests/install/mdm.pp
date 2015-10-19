class scaleio::install::mdm {

  if 'mdm' in $scaleio::components {
    include scaleio::shm
    
    package { ['mutt', 'python', 'python-paramiko' ]:
      ensure => present,
    } ->
    package { $scaleio::pkgs['mdm']:
      ensure  => $scaleio::version,
      require => Class[ '::scaleio::shm' ],
    }
  } else {
    notify {  'component "mdm" not specified':  }
  }

}
