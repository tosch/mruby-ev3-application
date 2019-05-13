module Ev3
  module Sensors
    # @return [String] the name of the sysfs class that contains sensor devices
    SYSFS_CLASS = 'lego-sensor'

    Generic = Class.new(Ev3::Device)
    Infrared = Class.new(Generic)
    UltraSonic = Class.new(Generic)
    Gyro = Class.new(Generic)
    Color = Class.new(Generic)
    Touch = Class.new(Generic)

    # @return [{String=>Ev3::Sensors::Generic}] an Hash that assigns driver names with specific Sensor classes
    KNOWN_DRIVERS = {
      'lego-ev3-ir' => Infrared,
      'lego-ev3-us' => UltraSonic,
      'lego-ev3-gyro' => Gyro,
      'lego-ev3-color' => Color,
      'lego-ev3-touch' => Touch
    }.freeze

    class << self
      # Fetches the list of available sensors from SYSFS_PATH and loads an instance of Sensors::Generic or a more specific class.
      #
      # @return [<Ev3::Sensors::Generic>]
      def detect
        detected_sensors = []

        Dir.foreach(File.join(Ev3.sysfs_class_path, SYSFS_CLASS)) do |node|
          next unless node.start_with?('sensor')

          sensor = load_sensor_from(node)
  
          detected_sensors << sensor unless sensor.nil?
        end

        detected_sensors
      end

      private

      def load_sensor_from(device_node)
        abs_path = File.join(Ev3.sysfs_class_path, SYSFS_CLASS, device_node)
        driver_name = File.read(File.join(abs_path, 'driver_name')).strip

        klass = KNOWN_DRIVERS[driver_name] || Generic

        klass.new(abs_path)
      rescue => e
        puts "Error while loading sensor from #{abs_path}"
        puts "#{e.class}: #{e.message}"
      end
    end
  end
end
