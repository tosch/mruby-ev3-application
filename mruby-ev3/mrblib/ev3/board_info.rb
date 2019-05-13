module Ev3
  # Information about the EV3 board
  class BoardInfo < Device
    SYSFS_CLASS = "board-info"

    class << self
      # Detect all available boards
      def detect
        detected_infos = []

        Dir.foreach(File.join(Ev3.sysfs_class_path, SYSFS_CLASS)) do |node|
          next unless node.start_with?('board')

          detected_infos << new(File.join(Ev3.sysfs_class_path, SYSFS_CLASS, node))
        end

        detected_infos
      end
    end

    def uevent
      read_attribute('uevent')
    end

    def hardware_revision
      parsed_uevent[:hw_rev]
    end

    def model
      parsed_uevent[:model]
    end

    def rom_revision
      parsed_uevent[:rom_rev]
    end

    def serial_number
      parsed_uevent[:serial_num]
    end

    def type
      parsed_uevent[:type]
    end

    private

    def parsed_uevent
      @parsed_uevent ||= Hash[
        uevent.each_line.map do |line|
          key, value = line.strip.sub(%r{^BOARD_INFO_}, '').split('=')

          key = key.downcase.to_sym

          [key, value]
        end
      ]
    end
  end
end
