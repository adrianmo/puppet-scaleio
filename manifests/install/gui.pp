class scaleio::install::gui {

  if 'gui' in $scaleio::components {
    package { $scaleio::pkgs['gui']:
    ensure   => $scaleio::version,
    }
  } else {
    notify {  'gui component not specified': }
  }

}
