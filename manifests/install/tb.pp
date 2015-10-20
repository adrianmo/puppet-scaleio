class scaleio::install::tb {

  if 'tb' in $scaleio::components {
    package { $scaleio::pkgs['tb']:
      ensure    => installed,
    }
  } else {
    notify { 'component "tb" not specified':  }
  }

}
