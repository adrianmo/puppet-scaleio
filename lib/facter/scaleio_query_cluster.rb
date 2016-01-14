require 'facter'

if File.exist?("/bin/emc/scaleio/drv_cfg.txt")
  drv_cfg_mdm_primary_ip = Facter::Util::Resolution.exec("/bin/cat /bin/emc/scaleio/drv_cfg.txt | grep \"^mdm\" | awk '{print $2}' 2> /dev/null")
  scaleio_version = Facter.value(:scaleio_version)
  if drv_cfg_mdm_primary_ip
    Facter.add("scaleio_primary_ip") do
      if scaleio_version == '1.32'
        setcode do
          Facter::Util::Resolution.exec("/bin/scli --mdm_ip #{drv_cfg_mdm_primary_ip} --query_cluster 2> /dev/null | grep 'Primary MDM IP' | awk '{print $4}'")
        end
      end
      if scaleio_version == '2.0'
        setcode do
          Facter::Util::Resolution.exec("/bin/scli --mdm_ip #{drv_cfg_mdm_primary_ip} --approve_certificate --query_cluster 2> /dev/null | grep -A 2 'Master MDM' | grep 'IPs' | awk '{print $2}' | rev | cut -c 2- | rev")
        end
      end
    end

    Facter.add("scaleio_secondary_ip") do
      if scaleio_version == '1.32'
        setcode do
          Facter::Util::Resolution.exec("/bin/scli --mdm_ip #{drv_cfg_mdm_primary_ip} --query_cluster 2> /dev/null | grep 'Secondary MDM IP' | awk '{print $4}'")
        end
      end
      if scaleio_version == '2.0'
        setcode do
          Facter::Util::Resolution.exec("/bin/scli --mdm_ip #{drv_cfg_mdm_primary_ip} --approve_certificate --query_cluster 2> /dev/null | grep -A 2 'Slave MDM' | grep 'IPs' | awk '{print $2}' | rev | cut -c 2- | rev")
        end
      end
    end

    Facter.add("scaleio_tb_ip") do
      if scaleio_version == '1.32'
        setcode do
          Facter::Util::Resolution.exec("/bin/scli --mdm_ip #{drv_cfg_mdm_primary_ip} --query_cluster 2> /dev/null | grep 'Tie-Breaker IP' | awk '{print $3}'")
        end
      end
      if scaleio_version == '2.0'
        setcode do
          Facter::Util::Resolution.exec("/bin/scli --mdm_ip #{drv_cfg_mdm_primary_ip} --approve_certificate --query_cluster 2> /dev/null | grep -A 2 'Tie-Breakers' | grep 'IPs' | awk '{print $2}' | rev | cut -c 2- | rev")
        end
      end
    end
  end
end
