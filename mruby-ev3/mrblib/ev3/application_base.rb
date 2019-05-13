module Ev3
  class ApplicationBase
    class << self
      def run
        new.join_loop
      end
    end

    attr_reader :event_listeners

    def initialize
      @event_listeners = {}

      setup
    end

    def setup
    end

    def in_loop
    end

    def join_loop
      loop do
        in_loop
      end
    end

    private

    def buttons
      Ev3.buttons
    end

    def leds
      Ev3.leds
    end

    def motors
      Ev3.motors
    end

    def sensors
      Ev3.sensors
    end

    def sound
      Ev3.sound
    end
  end
end
