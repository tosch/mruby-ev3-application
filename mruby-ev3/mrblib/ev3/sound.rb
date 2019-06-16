module Ev3
  class Sound
    def play_wav(file_path_or_symbol, block = false)
      file_path = if file_path_or_symbol.is_a?(Symbol)
        path_for_symbol(file_path_or_symbol) || raise(ArgumentError, "sound #{file_path_or_symbol} is unknown")
      else
        file_path_or_symbol
      end

      cmd = ['aplay', '-q']
      cmd << '-N' if block
      cmd << file_path

      IO.popen(cmd.join(' '))
    end

    def beep(frequency = 750, duration = 100, repetitions = 1, delay = 50)
      IO.popen("beep -f #{frequency} -l #{duration} -r #{repetitions} -D #{delay}")
    end

    def pcm_volume
      read_volume('PCM')
    end

    def pcm_volume=(value)
      write_volume('PCM', value)
    end

    def beep_volume
      read_volume('Beep')
    end

    def beep_volume=(value)
      write_volume('Beep', value)
    end

    private

    def path_for_symbol(symbol)
      parts = symbol.to_s.split('/')
      parts[-1] = "#{parts.last}.wav"
      path = File.join('/', 'usr', 'share', 'sounds', 'ev3dev', *parts)

      if File.exists?(path)
        path
      else
        nil
      end
    end

    def read_volume(type)
      output = `amixer sget #{type}`
      matches = output.match(%r{\[(\d+)%\]})
    end

    def write_volume(type, value)
      raise(ArgumentError, "value #{value} is invalid, must be within 0..100") unless (0..100).include?(value)

      IO.popen("amixer -q sset #{type} #{value}%")
    end
  end
end
