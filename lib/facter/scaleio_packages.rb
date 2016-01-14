require 'facter'

scaleio_version = Facter.value(:scaleio_version)

Facter.add("mdm_version") do
  confine :osfamily => :redhat
  release = Facter::Util::Resolution.exec("yum info --showduplicates EMC-ScaleIO-mdm |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end

Facter.add("tb_version") do
  confine :osfamily => :redhat
  if scaleio_version == '2.0'
    package_name = 'EMC-ScaleIO-mdm'
  else
    package_name = 'EMC-ScaleIO-tb'
  end
  release = Facter::Util::Resolution.exec("yum info --showduplicates #{package_name} |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end

Facter.add("sds_version") do
  confine :osfamily => :redhat
  release = Facter::Util::Resolution.exec("yum info --showduplicates EMC-ScaleIO-sds |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end

Facter.add("sdc_version") do
  confine :osfamily => :redhat
  release = Facter::Util::Resolution.exec("yum info --showduplicates EMC-ScaleIO-sdc |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end

Facter.add("gw_version") do
  confine :osfamily => :redhat
  release = Facter::Util::Resolution.exec("yum info --showduplicates EMC-ScaleIO-gateway |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end

Facter.add("gui_version") do
  confine :osfamily => :redhat
  release = Facter::Util::Resolution.exec("yum info --showduplicates EMC-ScaleIO-gui |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end

Facter.add("lia_version") do
  confine :osfamily => :redhat
  release = Facter::Util::Resolution.exec("yum info --showduplicates EMC-ScaleIO-lia |grep -A 1 ': #{scaleio_version}' |grep 'Release' |head -1 |awk '{print $3}'")
  setcode "#{scaleio_version}-#{release}"
end
