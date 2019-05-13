module Ev3
  class LEDList
    include Enumerable

    def initialize(leds)
      @leds = leds
    end

    def each
      @leds.each { |led| yield led }
    end

    def [](index)
      @leds[index]
    end

    def left
      @leds[0]
    end

    def right
      @leds[1]
    end

    def on(color)
      all? { |led| led.on(color) }
    end

    def off
      all? { |led| led.off }
    end
  end
end
