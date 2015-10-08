
class scaleio::shm inherits scaleio {
	$shm_size              = $scaleio::shm_size

	exec { 'shm':
	  command => "mount -o remount -o size=${shm_size} /dev/shm",
	  path => ["/bin","/usr/bin"],
	  onlyif => [ "/usr/bin/test `df -B1 /dev/shm |grep /dev/shm |awk '{ print $4 }'` -lt ${shm_size}" ],
	} ->

#	`cat /etc/fstab | grep "/dev/shm" | awk '{ print $4;}' | awk -F, '{ print $2}' | grep size | awk -F= '{ print $2}'`
	file_line { 'Replace a line in fstab':
	    path => '/etc/fstab',
	    match => "^tmpfs",
	    line => "tmpfs  /dev/shm  tmpfs defaults,size=${shm_size}  0 0",
	} ->

	exec { 'set kernel shmmax':
	  command   => 'sysctl -w kernel.shmmax=209715200',
	  logoutput => true,
	  path      => '/sbin',
		onlyif    => [ "/usr/bin/test `cat /proc/sys/kernel/shmmax` -lt 209715200" ],
	}
}
