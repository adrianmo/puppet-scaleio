
class scaleio::volume inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sdc_volume          = $scaleio::sio_sdc_volume

  define add_volume ($volumes, $mdm_ip, $volume_key = $title) {
    $volume = $volumes[$volume_key]
    $size_gb = $volumes['size_gb']
    $protection_domain = $volumes['protection_domain']
    $storage_pool = $volumes['storage_pool']
    if $storage_pool { $storage_pool_name = "--storage_pool_name '${storage_pool}'" }

    exec { "Add Volume ${volume_key}":
      command => "scli --add_volume --mdm_ip ${mdm_ip[0]} --size_gb ${size_gb} --volume_name ${volume_key} --protection_domain_name '${protection_domain}' ${storage_pool_name}",
      path    => '/bin',
      unless  => "scli --query_volume --mdm_ip ${mdm_ip[0]} --volume_name ${volume_key}",
      require => Class['::scaleio::login']
    }
  }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components and $scaleio_mdm_state == "Running" {
    if $sio_sdc_volume {
      $volume_keys = keys($sio_sdc_volume)
      add_volume { $volume_keys:
        volumes => $sio_sdc_volume,
        mdm_ip => $mdm_ip,
      }
    }
    else {
      notify { 'VOLUME - sio_sdc_volume not specified': }
    }
  }
  else {
    notify {'VOLUME - Not specified as secondary MDM or MDM not running':}
  }
}
