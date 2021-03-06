class scaleio::install::mdm {

  if 'mdm' in $scaleio::components {
    include scaleio::shm

    package { ['mutt', 'python', 'python-paramiko' ]:
      ensure => installed,
    } ->
    package { $scaleio::pkgs['mdm']:
      ensure  => $mdm_version,
      require => Class[ '::scaleio::shm' ],
    }
  } else {
    notify {  'component "mdm" not specified':  }
  }

}
