module Ev3
  module Sensors
    # Represents a touch sensor (a simple button)
    class Touch < Generic
      def released?
        value(0).zero?
      end

      def pressed?
        !released?
      end
    end
  end
end
