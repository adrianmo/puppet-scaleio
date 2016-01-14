class scaleio::install::callhome {

  if 'callhome' in $scaleio::components {
    package { $scaleio::pkgs['callhome']:
      ensure   => $scaleio::version,
    }
  } else {
    notify {  'callhome component not specified': }
  }

}
