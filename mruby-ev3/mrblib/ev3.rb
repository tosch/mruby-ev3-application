# Classes and methods for using LEGO EV3 components
#
# This requires [ev3dev](https://www.ev3dev.org/) as operating system.
#
# LEGO is a registered trademark of LEGO System A/S, Denmark. This code is in no way associated to LEGO.
module Ev3
  # @return [String] the path to the sysfs class directory
  SYSFS_CLASS_PATH = '/sys/class'

  class << self
    # @return [Ev3::Battery]
    def battery
      @battery ||= Ev3::Battery.detect
    end

    # @return [Ev3::DeviceList]
    def sensors
      @sensors ||= Ev3::DeviceList.new(Ev3::Sensors.detect)
    end

    # @return [Ev3::DeviceList]
    def motors
      @motors ||= Ev3::DeviceList.new(Ev3::Motors.detect)
    end

    # @return [Ev3::Sound]
    def sound
      @sound ||= Ev3::Sound.new
    end

    # @return [Ev3::LEDList]
    def leds
      @leds ||= Ev3::LEDList.new(Ev3::LEDs.detect)
    end

    # @return [Ev3::Buttons]
    def buttons
      @buttons ||= Ev3::Buttons.new
    end

    # @return [Ev3::BoardInfo]
    def board_info
      @board_info ||= Ev3::BoardInfo.detect.first # EV3 only has one board
    end

    # @return [String]
    def sysfs_class_path
      SYSFS_CLASS_PATH
    end
  end
end
