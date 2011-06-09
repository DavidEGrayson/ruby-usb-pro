module Usb::LangIds
  English_US = 0x0409
end

# Table 9-4: Standard Request Codes from USB Spec 2.0
module Usb::Requests
  GetStatus = 0
  ClearFeature = 1
  SetFeature = 2
  SetAddress = 5
  GetDescriptor = 6
  SetDescriptor = 7
  GetConfiguration = 8
  SetConfiguration = 9
  GetInterface = 10
  SetInterface = 11
  SynchFrame = 12
end

# Table 9-5: Descriptor Types
module Usb::DescriptorTypes
  Device = 1
  Configuration = 2
  String = 3
  Interface = 4
  Endpoint = 5
  DeviceQualifier = 6
  OtherSpeedConfiguration = 7
  InterfacePower = 8

  Table = {:device=>1, :configuration=>2, :config=>2,
      :string=>3, :interface=>4, :endpoint=>5,
      :device_qualifier=>6,
      :other_speed_configuration => 7,
      :other_speed_config => 7,
      :interface_power => 8}

  def self.find(sym)
    type = Table[sym]
  end
end
