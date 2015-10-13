class scaleio::sds inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sds_device          = $scaleio::sio_sds_device

  define add_sds_node ( $nodes, $mdm_ip, $node_key = $title ) {
    $node = $nodes[$node_key]
    $device_keys = keys($node['devices'])
    add_sds_device { $device_keys:
      node_name => $node_key,
      node => $node,
      devices => $node['devices'],
      mdm_ip => $mdm_ip,
    }
  }

  define add_sds_device ( $node_name, $node, $devices, $mdm_ip, $device_path = $title ) {
    $device = $devices[$device_path]
    $storage_pool = $device['storage_pool']
    if $storage_pool { $storage_pool_name = "--storage_pool_name '${storage_pool}'" }
    exec { "Add SDS ${node_name} device ${device_path}":
      command => "scli --add_sds_device --mdm_ip ${mdm_ip[0]} --sds_ip ${node['ip']} --device_path ${device_path} ${storage_pool_name}",
      path    => '/bin',
      unless  => "scli --query_sds --mdm_ip ${mdm_ip[0]} --sds_name ${node_name} | grep ' Path: ${device_path}'",
      require => Class['::scaleio::login']
    }
  }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components and $scaleio_mdm_state == "Running" {

    if $sio_sds_device {
      $node_keys = keys($sio_sds_device)
      add_sds_node { $node_keys:
        nodes => $sio_sds_device,
        mdm_ip => $mdm_ip,
      }
    }
    else {
      notify {'SDS - No sio_sds_device specified':}
    }
  }
  else {
    notify {'SDS - Not specified as secondary MDM or MDM not running':}
  }
}
