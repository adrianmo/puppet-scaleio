
class scaleio::drv_cfg inherits scaleio {
	$mdm_ip              = $scaleio::mdm_ip
	$drv_cfg_file				 = $scaleio::drv_cfg_file

  if $mdm_ip {
      $drv_mdm_ips = join($mdm_ip,' ')
	    $drv_mdm = "mdm ${drv_mdm_ips}"

	    file { [ "/bin/emc", "/bin/emc/scaleio" ]:
	      ensure => "directory",
	    }

	    file { "$drv_cfg_file":
	      ensure => present,
				require => File['/bin/emc/scaleio'],
	    }

	    file_line { 'Append a line to drv_cfg.txt':
	      path => $drv_cfg_file,
	      match => "^mdm ",
	      line => $drv_mdm,
				require => File["${drv_cfg_file}"],
	    }
	}
}
