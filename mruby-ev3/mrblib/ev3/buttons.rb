module Ev3
  class Buttons
    INPUT_EVENT_FILE = '/dev/input/by-path/platform-gpio_keys-event'

    EVENT_SIZE = 24
    EVENT_FORMAT = 'L!2S!2I!'

    CODE_TO_KEYS = {
      14 => :back,
      28 => :center,
      103 => :up,
      105 => :left,
      106 => :right,
      108 => :down
    }.freeze

    def wait_for(key)
      raise(ArgumentError, "Unknown key #{key}.") unless CODE_TO_KEYS.value?(key)

      io = _open_io

      loop do
        break if _read_key(io) == key
      end
    ensure
      io.close unless !io || io.closed?
    end

    def _open_io
      File.open(INPUT_EVENT_FILE, 'rb')
    end

    def _read_key(io)
      raw_data = io.read(EVENT_SIZE)

      return nil unless raw_data && raw_data.size == EVENT_SIZE

      data = raw_data.unpack(EVENT_FORMAT)
      return nil unless data[2] == 1

      CODE_TO_KEYS[data[3]]
    end
  end
end
