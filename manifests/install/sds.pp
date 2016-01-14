class scaleio::install::sds {

  if 'sds' in $scaleio::components {
    package { $scaleio::pkgs['sds']:
      ensure   => $scaleio::version,
    }
  } else {
    notify {  'component "sds" not specified':  }
  }

}
