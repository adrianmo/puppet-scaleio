class scaleio::sds_first inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sds_device          = $scaleio::sio_sds_device

  define add_sds ( $nodes, $mdm_ip, $node_key = $title ) {
    $node = $nodes[$node_key]
    $device_keys = keys($node['devices'])
    $device_path = $device_keys[0]
    $device = $node['devices'][$device_path]
    $protection_domain = $node['protection_domain']
    $storage_pool  = $device['storage_pool']
    if $storage_pool { $storage_pool_name = "--storage_pool_name '${storage_pool}'" }

    exec { "Add SDS ${node_key} for first device ${device_path}":
      command => "scli --add_sds --mdm_ip ${mdm_ip[0]} --sds_ip ${node['ip']} --sds_name ${node_key} --protection_domain_name '${protection_domain}' --device_path ${device_path} ${storage_pool_name}",
      path    => '/bin',
      unless  => "scli --query_sds --mdm_ip ${mdm_ip[0]} --sds_name ${node_key}",
      require => Class['::scaleio::login']
    }
  }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components {

    if $sio_sds_device {
      $node_keys = keys($sio_sds_device)
      add_sds { $node_keys:
        nodes => $sio_sds_device,
        mdm_ip => $mdm_ip,
      }
    }
    else {
      notify {'SDS_FIRST - No sio_sds_device specified':}
    }
  }
  else {
    notify {'SDS_FIRST - Not specified as secondary MDM or MDM not running':}
  }
}
