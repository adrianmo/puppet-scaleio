class scaleio::install::tb {

  if 'tb' in $scaleio::components {
    package { $scaleio::pkgs['tb']:
      ensure    => $tb_version,
    }
  } else {
    notify { 'component "tb" not specified':  }
  }

}
