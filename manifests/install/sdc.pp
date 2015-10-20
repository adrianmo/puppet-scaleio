class scaleio::install::sdc {

  if 'sdc' in $scaleio::components {
    package { $scaleio::pkgs['sdc']:
      ensure   => installed,
    }
  } else {
    notify {  'sdc component not specified':  }
  }

}
