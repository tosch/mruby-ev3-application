module Ev3
  class DeviceList
    PORTS = {
      outA: 'ev3-ports:outA',
      outB: 'ev3-ports:outB',
      outC: 'ev3-ports:outC',
      outD: 'ev3-ports:outD',
      in1: 'ev3-ports:in1',
      in2: 'ev3-ports:in2',
      in3: 'ev3-ports:in3',
      in4: 'ev3-ports:in4',
    }.freeze

    include Enumerable

    attr_reader :devices

    # @param devices [<Ev3::Device>]
    def initialize(devices)
      @devices = Hash[devices.map { |device| [device.address, device] }]
    end

    # @yieldparam address [String] the address of the device, for example `ev3-ports:in1`
    # @yieldparam device [Ev3::Device]
    def each
      @devices.each { |address, device| yield address, device }
    end

    # @param address [String,Symbol] the address of the device
    #
    # @return [Ev3::Device, nil]
    def [](address)
      raise(ArgumentError, "unknown address #{address}") if address.is_a?(Symbol) && !PORTS.key?(address)

      address = PORTS[address] if address.is_a?(Symbol)

      @devices[address]
    end
  end
end
