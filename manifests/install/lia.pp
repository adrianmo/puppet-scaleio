class scaleio::install::lia {

  if 'lia' in $scaleio::components {
    package { $scaleio::pkgs['lia']:
      ensure   => $lia_version,
    }
  } else {
    notify {  'lia component not specified':  }
  }

}
