class scaleio::install::gw {

  if 'gw' in $scaleio::components {
    package { 'java-1.8.0-openjdk-devel':
      ensure  => installed,
    }

    package { $scaleio::pkgs['gw']:
      ensure  => $scaleio::version,
      require => Package['java-1.8.0-openjdk-devel'],
    }
  } else {
    notify {  'gw component not specified': }
  }
}
