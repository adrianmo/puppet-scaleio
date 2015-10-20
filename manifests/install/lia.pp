class scaleio::install::lia {

  if 'lia' in $scaleio::components {
    package { $scaleio::pkgs['lia']:
      ensure   => installed,
    }
  } else {
    notify {  'lia component not specified':  }
  }

}
