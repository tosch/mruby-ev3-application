module Ev3
  # Base class suitable for most devices that are driven by ev3dev
  class Device
    # @return [String] the absolute path to the sysfs directory for the device
    attr_reader :device_node

    # @param device_node [String] The absolute path to the sysfs directory that contains information about the device.
    def initialize(device_node)
      @device_node = device_node
    end

    # @return [String] The address of the device, for example `ev3-ports:in1` or `ev3-ports:outa`
    def address
      @address ||= read_attribute('address')
    end

    # Sends a command to the device.
    #
    # @param command [String] Any String that is included in #commands.
    #
    # @return [String] The command that has been sent to the device.
    #
    # @raise [ArgumentError] when the given command is not included in #commands
    def command=(command)
      raise ArgumentError.new("Invalid command #{command}. Valid commands are #{commands.join(', ')}.") unless commands.include?(command)

      write_attribute('command', command)
    end
    alias_method :send_command, :command=

    # @return [<Symbol>] A list of commands available for the device.
    def commands
      @commands ||= read_attribute('commands').split(' ').map(&:to_sym)
    end

    # @return [String] The name of the ev3dev driver used for the device.
    def driver_name
      @driver_name ||= read_attribute('driver_name')
    end

    private

    def read_attribute(name, opts = nil)
      path = File.join(device_node, name)

      if File.exists?(path)
        value = File.read(path, opts)
        value = value.strip if opts.nil? && value.respond_to?(:strip)
        value
      else
        nil
      end
    end

    def write_attribute(name, value)
      File.open(File.join(device_node, name), 'w') { |file| file.write(value) }
    end
  end
end
