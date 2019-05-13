module Ev3
  module Sensors
    # Represents a color sensor
    #
    # TODO: Allow calibrating the reflected light value as it is returned as relative value. It might be possible to use `REF-RAW`
    #   mode for this.
    class Color < Generic
      COLORS = {
        none: 0,
        black: 1,
        blue: 2,
        green: 3,
        yellow: 4,
        red: 5,
        white: 6,
        brown: 7
      }.freeze

      COLORS_BY_CODE = COLORS.invert.freeze

      COLORS.each do |name, code|
        define_method(:"#{name}?") do
          raise(RuntimeError, 'the sensor must be in "COL-COLOR" mode') unless mode == "COL-COLOR"

          self.value(0) == code
        end
      end

      # Puts the sensor into color detection mode and returns the name of the detected color
      #
      # @return [Symbol] The detected color. See COLORS for a list of possible values.
      def color
        self.mode = 'COL-COLOR' unless mode == 'COL-COLOR'

        COLORS_BY_CODE.fetch(value(0))
      end

      # Puts the sensor into ambient light detection mode and returns the relative ambient light.
      #
      # @return [Integer] between 0 and 100
      def ambient_light
        self.mode = 'COL-AMBIENT' unless mode == 'COL-AMBIENT'

        value(0)
      end

      # Puts the sensor into reflected light detection mode and returns the relative amount of reflected light.
      #
      # @return [Integer] between 0 and 100
      def reflected_light
        self.mode = 'COL-REFLECT' unless mode == 'COL-REFLECT'

        value(0)
      end

      # Puts the sensor into raw RGB detection mode and returns the raw values for the red, green and blue components
      # of the reflected light.
      #
      # @return [{:red,:green,:blue=>Integer}]
      def rgb
        self.mode = 'RGB-RAW' unless mode == 'RGB-RAW'

        { red: value(0), green: value(1), blue: value(2) }
      end
    end
  end
end
