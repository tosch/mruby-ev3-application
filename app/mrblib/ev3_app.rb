# Classes and methods for using LEGO EV3 components
# 
# This requires [ev3dev](https://www.ev3dev.org/) as operating system.
#
# LEGO is a registered trademark of LEGO System A/S, Denmark. This code is in no way associated to LEGO.
module Ev3
  class Device
    attr_reader :device_node

    def initialize(device_node)
      @device_node = device_node
    end

    def address
      @address ||= read_attribute('address')
    end

    def command=(command)
      raise ArgumentError.new("Invalid command #{command}. Valid commands are #{commands.join(', ')}.") unless commands.include?(command)

      write_attribute('command', command)
    end

    def commands
      @commands ||= read_attribute('commands').split(' ')
    end

    def driver_name
      @driver_name ||= read_attribute('driver_name')
    end

    private

    def read_attribute(name)
      File.read(File.join(device_node, name))
    end

    def write_attribute(name, value)
      File.write(File.join(device_node, name), value)
    end
  end

  module Sensors
    class Generic < ::Ev3::Device
      # @return [String] unformatted data
      def bin_data
        read_attribute('bin_data')
      end

      # @return [String] the format of the raw binary data
      def bin_data_format
        read_attribute('bin_data_format')
      end

      def decimals
        read_attribute('decimals')
      end

      def driver_name
        @driver_name ||= read_attribute('driver_name')
      end

      def fw_version
        @fw_version ||= read_attribute('fw_version')
      end

      # TODO: Cache value and wait for `change` uevent
      def mode
        read_attribute('mode')
      end

      def mode=(value)
        raise ArgumentError.new("Invalid mode #{value}. Valid modes are #{modes.join(', ')}.") unless modes.include?(value)

        write_attribute('mode', value)
      end

      def modes
        @modes ||= read_attribute('modes').split(' ')
      end

      def num_values
        read_attribute('num_values').to_i
      end

      def poll_ms
        read_attribute('poll_ms')
      end

      def units
        read_attribute('units')
      end

      def text_value
        read_attribute('text_value')
      end

      def method_missing(name, *args, &block)
        if name.to_s.match?(/^value(#{allowed_value_numbers.join('|')})$/)
          read_attribute(name)
        else
          super
        end
      end

      private

      def allowed_value_numbers
        (0...num_values).to_a
      end
    end

    class UltraSonic < Generic
    end

    class Color < Generic
    end

    class Touch < Generic
    end

    class Gyro < Generic
    end

    SYSFS_PATH = '/sys/class/lego-sensor'

    KNOWN_DRIVERS = {
      'lego-ev3-us' => UltraSonic,
      'lego-ev3-gyro' => Gyro,
      'lego-ev3-color' => Color,
      'lego-ev3-touch' => Touch
    }.freeze

    class << self
      def detect
        detected_sensors = []

        Dir.foreach(SYSFS_PATH) do |node|
          next unless node.match?(/^sensor[\d]+$/)

          driver_name = File.read(File.join(SYSFS_PATH, node, 'driver_name'))

          klass = KNOWN_DRIVERS[driver_name] || Generic

          detected_sensors << klass.new(node)
        end

        detected_sensors
      end
    end
  end

  module Motors
    class Generic < ::Ev3::Device
    end

    class Large < Generic
    end

    class Medium < Generic
    end

    SYSFS_PATH = '/sys/class/tacho-motor'

    KNOWN_DRIVERS = {}

    class << self
      def detect
        detected_sensors = []

        Dir.foreach(SYSFS_PATH) do |node|
          next unless node.match?(/^motor[\d]+$/)

          driver_name = File.read(File.join(SYSFS_PATH, node, 'driver_name'))

          klass = KNOWN_DRIVERS[driver_name] || Generic

          detected_sensors << klass.new(node)
        end

        detected_sensors
      end
    end
  end

  class << self
    def sensors
      @sensors ||= Ev3::Sensors.detect
    end

    def motors
      @motors ||= Ev3::Motors.detect
    end
  end
end

class Ev3App
  def self.run
    puts 'hello world'
  end  
end

puts 'hello from after class definitions'

Ev3App.run

