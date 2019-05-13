module Ev3
  module Sensors
    # Represents a generic sensor. This class will be used when mruby-ev3 has not implemented any more specific class for the sensor.
    class Generic < ::Ev3::Device
      # @return [String] unformatted data
      def bin_data
        read_attribute('bin_data', {'mode' => 'rb'})
      end

      # @return [String] The format of the raw binary data
      def bin_data_format
        read_attribute('bin_data_format')
      end

      def decimals
        read_attribute('decimals').to_i
      end

      # @return [String] The current mode of the sensor.
      #
      # @todo Cache value and wait for `change` uevent
      def mode
        read_attribute('mode')
      end

      # Sets the mode of the sensor.
      #
      # @param value [String] Any value that is included in #modes
      #
      # @return [String] The mode that has been set
      #
      # @raise [ArgumentError] when the given value is not included in #modes
      def mode=(value)
        raise ArgumentError.new("Invalid mode #{value}. Valid modes are #{modes.join(', ')}.") unless modes.include?(value)

        write_attribute('mode', value)
      end

      # @return [<String>] A list of modes available for the given sensor.
      def modes
        @modes ||= read_attribute('modes').split(' ')
      end

      # @return [Integer] The number of values available for the current sensor mode.
      def num_values
        read_attribute('num_values').to_i
      end

      # @return [Integer, nil] The number of miliseconds between two polls of the sensor or nil when not available.
      def poll_ms
        value = read_attribute('poll_ms')

        value.empty? ? nil : value.to_i
      end

      # @return [String] The units of the sensor data.
      def units
        read_attribute('units')
      end

      # @return [String] The value(s) as readable text. Only available for some sensors.
      def text_value
        read_attribute('text_value')
      end

      def value(number)
        raise ArgumentError, "invalid number #{number} given, must be between 0 and #{num_values - 1}." if number >= num_values

        val = read_attribute("value#{number}").to_i
        val = Rational(val, 10**decimals) unless decimals.zero?
        val
      end

      def formatted_value(number)
        "#{value(number).to_f} #{units}"
      end

      def values
        num_values.times.map { |i| value(i) }
      end

      private

      def allowed_value_numbers
        (0...num_values).to_a
      end
    end
  end
end
