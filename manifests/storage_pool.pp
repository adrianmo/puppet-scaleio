
class scaleio::storage_pool inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sds_device          = $scaleio::sio_sds_device

  define enable_storage_pool ( $nodes, $mdm_ip, $node_name = $title ) {
    $node = $nodes[$node_name]
    $devices = $node['devices']
    $protection_domain = $node['protection_domain']
    $device_keys = keys($devices)
    # enable_storage_pool_device { $device_keys:
    #   node_name => $node_name,
    #   protection_domain => $protection_domain,
    #   devices => $node['devices'],
    #   mdm_ip => $mdm_ip,
    # }
    $device_path = $device_keys[0]
    $device = $devices[$device_path]
    $storage_pool = $device['storage_pool']
    if $storage_pool {
      exec { "Enable storage pool '${storage_pool}' for protection domain '${protection_domain}' and SDS '${node_name}' and device '${device_path}'":
        command => "scli --add_storage_pool --mdm_ip ${mdm_ip[0]} --protection_domain_name '${protection_domain}' --storage_pool_name '${storage_pool}'",
        path    => '/bin',
        unless  => "scli --query_storage_pool --mdm_ip ${mdm_ip[0]} --protection_domain_name '${protection_domain}' --storage_pool_name '${storage_pool}'",
        require => Class['::scaleio::login']
      }
    }
  }

  # define enable_storage_pool_device ( $node_name, $protection_domain, $devices, $mdm_ip, $device_path = $title ) {
  #   $device = $devices[$device_path]
  #   $storage_pool = $device['storage_pool']
  #   if $storage_pool {
  #     exec { "Enable storage pool '${storage_pool}' for protection domain '${protection_domain}' and SDS ${node_name} and device '{$device_path}'":
  #       command => "scli --add_storage_pool --mdm_ip ${mdm_ip[0]} --protection_domain_name '${protection_domain}' --storage_pool_name '${storage_pool}'",
  #       path    => '/bin',
  #       unless  => "scli --query_storage_pool --mdm_ip ${mdm_ip[0]} --protection_domain_name '${protection_domain}' --storage_pool_name '${storage_pool}'",
  #       require => Class['::scaleio::login']
  #     }
  #   }
  # }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components {
    if $sio_sds_device {
      $node_keys = keys($sio_sds_device)
      enable_storage_pool { $node_keys:
        nodes => $sio_sds_device,
        mdm_ip => $mdm_ip,
      }
    } else {
      notify {  'Storage Pool - sio_sdc_volume not specified':  }
    }
  } else {
    notify {  'Storage Pool - Not specified as secondary MDM or MDM not running': }
  }
}
