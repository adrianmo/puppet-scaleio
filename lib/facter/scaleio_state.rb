require 'facter'

Facter.add("scaleio_mdm_state") do
  setcode do

  output = Facter::Util::Resolution.exec('pgrep mdm')

  "Running" if output
  end
end

Facter.add("scaleio_sds_state") do
  setcode do

  output = Facter::Util::Resolution.exec('pgrep sds')

  "Running" if output
  end
end
