module Usb::Cdc
  ClassCode = 2

  # CDC 1.20 Table 4: Class Subclass Code
  module SubclassCodes
    DirectLineControlModel = 1
    AbstractControlModel = 2
    TelephoneControlModel = 3
    MultiChannelControlModel = 4
    CapiControlModel = 5
    EthernetNetworkingControlModel = 6
    AtmNetworkingControlModel = 7
    WirelessHandsetControlModel = 8
    DeviceManagement = 9
    MobileDirectLineModel = 10
    Obex = 11
    EthernetEmulationModel = 12
    NetworkControlModel = 13
  end

  # CDC 1.20 Table 5: Communications Interface Class Control Protocol Codes
  module ProtocolCodes
    AT_V250 = 1
    AT_PCCA101 = 2
    AT_PCCA101AndAnnexO = 3
    AT_GSN7_07 = 4
    AT_3GPP27_07 = 5
    AT_TIA_CDMA = 6
    USB_EEM = 7
    External = 0xFE
  end

  # Header Functional Descriptor, which marks the beginning of the
  # concatenated set of functional descriptors for the interface.
  # See Table 15 in CDC1.20.
  class HeaderDescriptor < Usb::Descriptors::Descriptor
    class_specific ClassCode, :interface, 0x00
    uint16 :bcdCDC
  end

  # See Table 13 in PSTN1.20.
  class CallManagementFunctionalDescriptor < Usb::Descriptors::Descriptor
    class_specific ClassCode, :interface, 0x01
    uint8 :bmCapabilities
    uint8 :bDataInterface

    def capable?(bit_number)
      (@bmCapabilities >> bit_number & 1) == 1
    end

    def manages_calls?
      capable? 0
    end

    def manages_calls_over_data_interface?
      capable? 1
    end
  end

  # See Table 4 in PSTN1.20.
  class AbstractControlManagementFunctionalDescriptor < Usb::Descriptors::Descriptor
    class_specific ClassCode, :interface, 0x02
    uint8 :bmCapabilities

    def capable?(bit_number)
      (@bmCapabilities >> bit_number & 1) == 1
    end

    def supports_network_connection_notification?
      capable? 3
    end

    def supports_send_break?
      capable? 2
    end

    def supports_control_lines?
      capable? 1
    end

    def supports_comm_feature?
      capable? 0
    end
  end

  # See Table 16 of CDC1.20.
  class UnionFunctionalDescriptor < Usb::Descriptors::Descriptor
    class_specific ClassCode, :interface, 0x06
    attr_accessor :bControlInterface
    attr_accessor :subordinate_interfaces

    def initialize
      super
      @subordinate_interfaces = []
    end

    def self.from_binary(binary)
      desc = new
      desc.bLength, desc.bDescriptorType, desc.bDescriptorSubtype, desc.bControlInterface = binary.unpack('CCCC')
      desc.subordinate_interfaces = binary[4..-1].bytes
      return desc
    end
  end
  
end
