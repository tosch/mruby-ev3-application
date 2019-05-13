module Ev3
  module LEDs
    class BuiltIn
      COLORS = {
        black: { green: 0, red: 0 },
        red: { green: 0, red: 100 },
        green: { green: 100, red: 0 },
        amber: { green: 100, red: 100 },
        orange: { green: 50, red: 100 },
        yellow: { green: 100, red: 10 }
      }

      RELATIVE_BRIGHTNESSES = (0..100).freeze

      attr_reader :base_path, :number

      def initialize(base_path, number)
        @base_path = base_path
        @number = number
        @max_brightnesses = {}
      end

      def device_node_for(color)
        File.join(base_path, "led#{number}:#{color}:brick-status")
      end

      def green
        read_attribute_from('green', 'brightness')
      end

      def green=(brightness)
        set_brightness_on('green', brightness)
      end

      def max_brightness_for(color)
        return @max_brightnesses[color] if @max_brightnesses.key?(color)

        @max_brightnesses[color] = read_attribute_from(color, 'max_brightness')
      end

      def off
        (self.green = 0) && (self.red = 0)
      end

      def on(color_definition)
        raise ArgumentError, "Invalid color #{color_definition}" unless valid_color_definition?(color_definition)

        color_definition = COLORS[color_definition] if color_definition.is_a?(Symbol)

        (self.red = color_definition[:red]) && (self.green = color_definition[:green])
      end

      def red
        read_attribute_from('red', 'brightness')
      end

      def red=(brightness)
        set_brightness_on('red', brightness)
      end

      private

      def valid_color_definition?(color_definition)
        (color_definition.is_a?(Symbol) && COLORS.key?(color_definition)) ||
          (valid_relative_value?(color_definition[:green]) && valid_relative_value?(color_definition[:red]))
      end

      def valid_relative_value?(brightness)
        RELATIVE_BRIGHTNESSES.include?(brightness)
      end

      def to_absolute_brightness_for(color, relative_brightness)
        (Rational(relative_brightness, 100) * max_brightness_for(color)).round
      end

      def read_attribute_from(color, name)
        path = File.join(device_node_for(color), name)

        if File.exists?(path)
          File.read(path)&.strip.to_i
        else
          nil
        end
      end

      def write_attribute_to(color, name, value)
        path = File.join(device_node_for(color), name)

        File.open(path, 'w') { |file| file.write(value) }
      end

      def set_brightness_on(color, brightness)
        raise(ArgumentError, "Given #{brightness} is out of allowed range #{RELATIVE_BRIGHTNESSES}") unless valid_relative_value?(brightness)

        write_attribute_to(color, 'brightness', to_absolute_brightness_for(color, brightness).to_s)
      end
    end
  end
end
