class scaleio::install::gui {

  if 'gui' in $scaleio::components {
    package { 'java-1.8.0-openjdk-devel':
      ensure  => installed,
    }

    package { $scaleio::pkgs['gui']:
      ensure   => installed,
      require => Package['java-1.8.0-openjdk-devel'],
    }
  } else {
    notify {  'gui component not specified': }
  }

}
