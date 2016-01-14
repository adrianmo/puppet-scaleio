
class scaleio::mdm inherits scaleio {

  $enable_cluster_mode     = $scaleio::enable_cluster_mode
  $cluster_name            = $scaleio::cluster_name
  $password                = $scaleio::password
  $tb_ip                   = $scaleio::tb_ip
  $version                 = $scaleio::version
  $default_password        = $scaleio::default_password
  $mdm_ip                  = $scaleio::mdm_ip
  $components              = $scaleio::components
  $sio_sdc_volume          = $scaleio::sio_sdc_volume

  include wait_for

  define add_to_environment ($mdm_ip) {
    $join_mdm_ip = join($mdm_ip,',')
    file_line { 'Append line for mdm_ip to /etc/environment':
        path  => '/etc/environment',
        match => "^mdm_ip=",
        line  => "mdm_ip=${join_mdm_ip}",
    }
  }

  define add_primary_mdm ($scaleio_mdm_state, $scaleio_primary_ip, $mdm_ip, $version) {

    if !$scaleio_primary_ip or $scaleio_primary_ip == 'N/A' {
      if $version == '1.32' {
        exec { 'Add Primary MDM':
          command => "scli --mdm --add_primary_mdm --primary_mdm_ip ${mdm_ip[0]} --mdm_management_ip ${mdm_ip[0]} --accept_license",
          path    => '/bin',
        }
      }
      if $version == '2.0' {
        exec { 'Add Primary MDM':
          command => "scli --approve_certificate --accept_license --create_mdm_cluster  --use_nonsecure_communication --master_mdm_ip ${mdm_ip[0]}",
          path    => '/bin',
        }
      }
    } else {
      notify {'Skipped Add Primary MDM': }
    }
  }

  define change_password ($scaleio_secondary_ip, $scaleio_mdm_state, $password, $default_password, $mdm_ip, $version) {

    if $version == '2.0' {
      $approve_certificate = '--approve_certificate'
    } else {
      $approve_certificate = ''
    }

    notify { "scaleio_secondary_ip = '${scaleio_secondary_ip}'":}  ->
    notify { "scaleio_mdm_state = '${scaleio_mdm_state}'":}  ->
    notify { "default_password: ${default_password}, password: ${password}": } ->
    notify { "MDMs: ${mdm_ip}": }
    # !facter represents a missing facter, hence a first puppet run before mdm service
    if !$scaleio_secondary_ip or $scaleio_secondary_ip == 'N/A' {
      exec { '1st Login':
        command => "scli --mdm_ip ${mdm_ip[0]} ${approve_certificate} --login --username admin --password ${default_password}",
        path    => '/bin',
      } ->
      exec { 'Set 1st Password':
        command => "scli --mdm_ip ${mdm_ip[0]} --set_password --old_password admin --new_password ${password}",
        path    => '/bin',
      } ->
      exec { '1st Login New Password':
        command => "scli --mdm_ip ${mdm_ip[0]} --login --username admin --password ${password}",
        path    => '/bin',
      }
    }  else { notify {'Skipped Password Set and 2nd MDM Add': } }
  }

  define add_secondary_mdm ($scaleio_mdm_state, $scaleio_secondary_ip, $mdm_ip, $version) {

    notify {"Adding Secondary MDM IP: '${scaleio_secondary_ip}'": }
    #using mdm_ip versus scaleio_primary_ip since scaleio_primary_ip may not be populated if first run

    if !$scaleio_secondary_ip or $scaleio_secondary_ip == 'N/A' {
      if $version == '1.32' {
        exec { 'Add Secondary MDM':
          command => "scli --add_secondary_mdm --mdm_ip ${mdm_ip[0]} --secondary_mdm_ip ${mdm_ip[1]}",
          path    => '/bin',
          require => Class['::scaleio::login']
        }
      }
      if $version == '2.0' {
        exec { 'Add Secondary MDM':
          command => "scli --add_standby_mdm --mdm_ip ${mdm_ip[0]} --new_mdm_ip ${mdm_ip[1]} --mdm_role manager --new_mdm_name mdm-slave",
          path    => '/bin',
          require => Class['::scaleio::login']
        }
      }
    } else { notify {'Secondary MDM already exists':} }
  }

  define add_tiebreaker ($scaleio_mdm_state, $scaleio_tb_ip, $tb_ip, $mdm_ip, $version) {

    notify {"Adding Tie-Breaker. TB IP: '${scaleio_tb_ip}'": }
    #using mdm_ip versus scaleio_primary_ip since scaleio_primary_ip may not be populated if first run

    if !$scaleio_tb_ip or $scaleio_tb_ip == 'N/A' {
      if $version == '1.32' {
        exec { 'Add TB':
          command => "scli --add_tb --mdm_ip ${mdm_ip[0]} --tb_ip ${tb_ip}",
          path    => '/bin',
          require => Class['::scaleio::login']
        }
      }
      if $version == '2.0' {
        exec { 'Add TB':
          command => "scli --add_standby_mdm --mdm_ip ${mdm_ip[0]} --new_mdm_ip ${tb_ip} --mdm_role tb --new_mdm_name mdm-tb",
          path    => '/bin',
          require => Class['::scaleio::login']
        }
      }
    } else { notify {'Tie-Breaker already exists':} }
  }


  define switch_to_cluster_mode ($enable_cluster_mode, $mdm_ip, $tb_ip, $version) {
    notify {"Enable cluster mode: ${enable_cluster_mode}": }

    if $enable_cluster_mode {
      if $version == '1.32' {
        exec { 'Switch to Cluster Mode':
          command => "scli --mdm_ip ${mdm_ip[0]} --switch_to_cluster_mode",
          path    => '/bin',
          onlyif  => "scli --query_cluster --mdm_ip ${mdm_ip[0]} | grep 'Mode: Single'",
          require => Class['::scaleio::login']
        }
      }
      if $version == '2.0' {
        exec { 'Switch to Cluster Mode':
          command => "scli --mdm_ip ${mdm_ip[0]} --switch_cluster_mode --cluster_mode 3_node --add_slave_mdm_ip ${mdm_ip[1]} --add_tb_ip ${tb_ip}",
          path    => '/bin',
          onlyif  => "scli --query_cluster --mdm_ip ${mdm_ip[0]} | grep 'Mode: Single'",
          require => Class['::scaleio::login']
        }
      }

    } else { notify {'Cluster Mode not required':} }
  }

  define rename_cluster ($cluster_name, $mdm_ip) {
    notify {"Rename cluster to '${cluster_name}'": }

    if $cluster_name {
      exec { 'Rename Cluster':
        command => "scli --mdm_ip ${mdm_ip[0]} --rename_system --new_name '${cluster_name}'",
        path    => '/bin',
        unless  => "scli --query_cluster --mdm_ip ${mdm_ip[0]} | grep \"Name: ${cluster_name}\"",
        require => Class['::scaleio::login']
      }
    } else { notify {'Cluster Name not specified':} }
  }


  if 'mdm' in $components {

    if $mdm_ip[0] in $ip_address_array {
      notify { 'This is the primary MDM': } ->

      add_to_environment { 'Add MDM IP to environment':
        mdm_ip => $mdm_ip,
      } ->

      exec { 'Wait (2 minutes)':
        command => 'sleep 120',
        path    => '/usr/bin:/bin',
        timeout => 150,
      } ->

      wait_for { 'pgrep mdm':
        exit_code         => 0,
        polling_frequency => 60,
        max_retries       => 10,
      } ->

      notify { "scaleio_primary_ip = ${scaleio_primary_ip}": } ->
      notify { "scaleio_mdm_state = ${scaleio_mdm_state}": } ->

      add_primary_mdm { 'Add Primary MDM':
        scaleio_mdm_state  => $scaleio_mdm_state,
        scaleio_primary_ip => $scaleio_primary_ip,
        mdm_ip             => $mdm_ip,
        version            => $version,
      }

    } else {
      notify {'Not primary MDM': }
    }

    if $mdm_ip[1] in $ip_address_array {

      notify {'This is the secondary MDM':} ->

      add_to_environment { 'Add MDM IP to environment':
        mdm_ip => $mdm_ip,
      } ->

      exec { 'Wait for primary MDM (10 minutes)':
        command => 'sleep 600',
        path    => '/usr/bin:/bin',
        timeout => 700,
      } ->

      wait_for { 'pgrep mdm':
        exit_code         => 0,
        polling_frequency => 60,
        max_retries       => 10,
      } ->

      notify { "scaleio_mdm_state = ${scaleio_mdm_state}": } ->
      notify { "scaleio_secondary_ip = ${scaleio_secondary_ip}": } ->

      change_password { 'Change ScaleIO password':
        scaleio_secondary_ip => $scaleio_secondary_ip,
        scaleio_mdm_state    => $scaleio_mdm_state,
        password             => $password,
        default_password     => $default_password,
        mdm_ip               => $mdm_ip,
        version              => $version,
      } ->

      # Perform a normal login
      class {'scaleio::login': } ->

      # Add Secondary MDM
      add_secondary_mdm { 'Add Secondary MDM':
        scaleio_mdm_state    => $scaleio_mdm_state,
        scaleio_secondary_ip => $scaleio_secondary_ip,
        mdm_ip               => $mdm_ip,
        version              => $version,
      } ->

      # Add Tie-Breaker
      add_tiebreaker { 'Add Tie-Breaker':
        scaleio_mdm_state => $scaleio_mdm_state,
        scaleio_tb_ip     => $scaleio_tb_ip,
        tb_ip             => $tb_ip,
        mdm_ip            => $mdm_ip,
        version           => $version,
      } ->

      switch_to_cluster_mode { 'Switch to cluster mode':
        enable_cluster_mode => $enable_cluster_mode,
        mdm_ip              => $mdm_ip,
        tb_ip               => $tb_ip,
        version             => $version,
      } ->

      rename_cluster { 'Rename cluster':
        cluster_name => $cluster_name,
        mdm_ip       => $mdm_ip,
      } ->

      notify { 'Secondary MDM configuration finished': }

    } else {
      notify {'Not secondary MDM': }
    }

  }
}
