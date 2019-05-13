module Ev3
  module LEDs
    # @return [String] the path to the SysFS nodes that control the LEDs.
    SYSFS_CLASS = 'leds'

    class << self
      # Detects the LEDs present
      # 
      # @todo Support LEDs that are not built in, but connected to the brick
      def detect
        [
          BuiltIn.new(File.join(Ev3::SYSFS_CLASS_PATH, SYSFS_CLASS), 0),
          BuiltIn.new(File.join(Ev3::SYSFS_CLASS_PATH, SYSFS_CLASS), 1)
        ]
      end
    end
  end
end
