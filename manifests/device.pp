
class scaleio::device inherits scaleio {

	define create_device ($devices, $device_path = $title) {
    notify { "Checking ${fqdn} device ${device_path}": }

		$device = $devices[$device_path]
		exec {"Truncate ${fqdn} device ${device_path}":
			command => "truncate -s ${device['size']} ${device_path}",
			logoutput => true,
			path => '/usr/bin',
			onlyif => [
			"/usr/bin/test ! -a ${device_path} -a ! -c ${device_path} -a ! -d ${device_path} -a ! -f ${device_path} -a ! -L ${device_path} -a ! -p ${device_path} -a ! -S ${device_path}"
						],
		}
  }

	if $sio_sds_device {
		$sds = $sio_sds_device[$fqdn]
		if $sds {
				notify { "Checking ${fqdn} devices": }

				$device_paths = keys($sds['devices'])
				create_device { $device_paths:
					devices => $sds['devices'],
				}

		} else {
			notify { "SDS ${fqdn} not configured for device": }
		}
  }
}
