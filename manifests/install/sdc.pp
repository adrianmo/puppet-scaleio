class scaleio::install::sdc {

  if 'sdc' in $scaleio::components {
    package { $scaleio::pkgs['sdc']:
      ensure   => $sdc_version,
    }
  } else {
    notify {  'sdc component not specified':  }
  }

}
