class scaleio::install::callhome {

  if 'callhome' in $scaleio::components {
    package { $scaleio::pkgs['callhome']:
      ensure   => installed,
    }
  } else {
    notify {  'callhome component not specified': }
  }

}
