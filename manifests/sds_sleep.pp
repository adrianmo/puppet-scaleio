class scaleio::sds_sleep inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sds_device          = $scaleio::sio_sds_device

  define add_sds_sleep ($nodes, $node_key = $title) {
    $node = $nodes[$node_key]
    exec {"Add SDS ${node} Sleep 30":
            command => 'sleep 30',
            path => '/bin',
            require => Class['::scaleio::login'],
            unless  => "/usr/bin/test ! `scli --query_sds --mdm_ip ${mdm_ip[0]} --sds_name ${node} | grep ' Path: ' -A1 | grep 'State: Initia'`",
    }
  }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components and $scaleio_mdm_state == "Running" {
    if $sio_sds_device {
      $node_keys = keys($sio_sds_device)
      add_sds_sleep { $node_keys:
        nodes => $sio_sds_device,
      }
    } else { notify {'SDS_SLEEP - No sio_sds_device specified':} }
  } else { notify {'SDS_SLEEP - Not specified as secondary MDM or MDM not running':} }
}
