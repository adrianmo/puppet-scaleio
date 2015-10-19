class scaleio::install::gw {

  if 'gw' in $scaleio::components {
    package { $scaleio::pkgs['gw']:
      ensure  => $scaleio::version,
      # require => Package[ 'java' ],
    }
  } else {
    notify {  'gw component not specified': }
  }

}
