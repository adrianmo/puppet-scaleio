
class scaleio::map_volume inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sdc_volume          = $scaleio::sio_sdc_volume

  define map_volume_to_sdc_ip ($volume_name, $mdm_ip, $sdc_ip = $title) {
    exec { "Add Volume ${volume_name} to SDC ${sdc_ip}":
      command => "scli --map_volume_to_sdc --mdm_ip ${mdm_ip[0]} --volume_name ${volume_name} --sdc_ip ${sdc_ip} --allow_multi_map",
      path    => '/bin',
      unless  => "scli --query_volume --mdm_ip ${mdm_ip[0]} --volume_name ${volume_name} | grep SDC | grep 'IP: ${sdc_ip}'",
      require => Class[ '::scaleio::login' ]
    }
  }

  define map_volume_to_sdc ($volumes, $mdm_ip, $volume_key = $title) {
    $volume = $volumes[$volume_key]
    $size_gb = $volume['size_gb']
    $protection_domain = $volume['protection_domain']
    $sdc_ips = $volume['sdc_ip']
    map_volume_to_sdc_ip { $sdc_ips:
      volume_name => $volume_key,
      mdm_ip => $mdm_ip,
    }
  }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components {
    if $sio_sdc_volume {
      $volume_keys = keys($sio_sdc_volume)
      map_volume_to_sdc { $volume_keys:
        volumes => $sio_sdc_volume,
        mdm_ip => $mdm_ip,
      }
    } else { notify { 'No volume specified or not configured as SDC': } }
  } else { notify {'Not on the secondary MDM or mdm not running':} }

}
