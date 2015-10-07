
class scaleio::protection_domain inherits scaleio {
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sds_device          = $scaleio::sio_sds_device

  define enable_protection_domain ($nodes, $node_key = $title) {
    $protection_domain = $nodes[$node_key]['protection_domain']
    exec { "Enable Protection Domain ${protection_domain} for SDS ${node}":
      command => "scli --add_protection_domain --mdm_ip ${mdm_ip[0]} --protection_domain_name '${protection_domain}'",
      path    => '/bin',
      unless  => "scli --query_all --mdm_ip ${mdm_ip[0]} | grep \"^Protection Domain ${protection_domain}\"",
      require => Class['::scaleio::login']
    }
  }

  if $mdm_ip[1] in $ip_address_array and 'mdm' in $components and $scaleio_mdm_state == 'Running' {
    if $sio_sds_device {
      $node_keys = keys($sio_sds_device)
      enable_protection_domain { $node_keys:
        nodes => $sio_sds_device,
      }
    } else {
      notify {  'Protection Domain - sio_sdc_volume not specified': }
    }
  } else {
    notify {  'Protection Domain - Not specified as secondary MDM or MDM not running':  }
  }
}
