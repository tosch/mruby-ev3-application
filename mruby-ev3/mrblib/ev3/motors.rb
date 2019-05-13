module Ev3
  module Motors
    # @return [String] The path to the SysFS directory that contains information about the available tacho motors.
    SYSFS_CLASS = 'tacho-motor'

    KNOWN_DRIVERS = {}

    class << self
      def detect
        detected_motors = []

        Dir.foreach(File.join(Ev3.sysfs_class_path, SYSFS_CLASS)) do |node|
          next unless node.start_with?('motor')
          abs_path = File.join(Ev3.sysfs_class_path, SYSFS_CLASS, node)

          driver_name = File.read(File.join(abs_path, 'driver_name')).strip

          klass = KNOWN_DRIVERS[driver_name] || Generic

          detected_motors << klass.new(abs_path)
        end

        detected_motors
      end
    end
  end
end
