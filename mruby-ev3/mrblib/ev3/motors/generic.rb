module Ev3
  module Motors
    class Generic < ::Ev3::Device
      # @return [Numeric] the number of counts per motor rotation
      def counts_per_rotation
        @counts_per_rotation ||= read_attribute('count_per_rot').to_i
      end

      # @return [Integer] the current duty cycle within -100..100
      def duty_cycle
        read_attribute('duty_cycle').to_i
      end
      
      # @return [Integer] the duty cycle setpoint used with command `run-direct`
      def duty_cycle_setpoint
        read_attribute('duty_cycle_sp').to_i
      end

      # @param value [Integer] the duty cycle setpoint used with command `run-direct`
      #
      # @raise [ArgumentError] when value is not within -100..100
      def duty_cycle_setpoint=(value)
        raise(ArgumentError, "given value #{value} is invalid") unless (-100..100).include?(value)

        write_attribute('duty_cycle_sp', value)
      end

      # @return [:normal, :inversed]
      def polarity
        read_attribute('polarity').to_sym
      end

      # @param [:normal, :inversed]
      #
      # @raise [ArgumentError] when value is not :normal or :inversed
      def polarity=(value)
        raise(ArgumentError, "given value #{value} is invalid") unless [:normal, :inversed].include?(value)

        write_attribute('polarity', value)
      end

      # @return [Integer] the current position of the motor
      def position
        read_attribute('position').to_i
      end

      # @param value [Integer]
      def position=(value)
        write_attribute('position', value)
      end

      # Returns the (theoretical) maximum speed of the motor. This is the maximum value allowed for #speed_setpoint=
      #
      # The physical speed of the motor will depend on battery voltage and motor load and will be lower than this value.
      #
      # @return [Integer] the maximum speed of the motor
      def max_speed
        @max_speed ||= read_attribute('max_speed').to_i
      end

      # @return [Integer] the target position for `run-to-abs-pos` and `run-to-rel-pos` commands
      def position_setpoint
        read_attribute('position_sp')
      end

      # Sets the target position for `run-to-abs-pos` and `run-to-rel-pos` commands
      #
      # @param value [Integer] 32 bit signed integer
      def position_setpoint=(value)
        write_attribute('position_sp', value)
      end

      # @return [Integer] the current speed of the motor in tacho counts per second
      def speed
        read_attribute('speed').to_i # TODO check if this is the correct numeric class
      end

      # @return [Integer] the motor speed in tacho counts per second for all `run-*` commands except `run-direct`
      def speed_setpoint
        read_attribute('speed_sp').to_i
      end

      # Sets the motor speed for all `run-*` commands except `run-direct`
      # 
      # @param value [Integer] 32 bit signed integer, in tacho counts per second
      #
      # @raise [ArgumentError] when value is 
      def speed_setpoint=(value)
        raise(ArgumentError, "given value #{value} is invalid") unless ((-1 * max_speed)..max_speed).include?(value)

        write_attribute('speed_sp', value)
      end

      # @return [Integer] the desired ramp up time in miliseconds
      def ramp_up_setpoint
        read_attribute('ramp_up_sp').to_i
      end

      # @param value [Integer] the desired ramp up time in miliseconds. Must not be negative. Set to zero to disable ramp up
      def ramp_up_setpoint=(value)
        raise(ArgumentError, "given value #{value} is invalid") if 0 > value

        write_attribute('ramp_up_sp', value)
      end

      # @return [Integer] the desired ramp down time in miliseconds
      def ramp_down_setpoint
        read_attribute('ramp_down_sp').to_i
      end

      # @param value [Integer] the desired ramp down time in miliseconds. Must not be negative.
      def ramp_down_setpoint=(value)
        raise(ArgumentError, "given value #{value} is invalid") if 0 > value

        write_attribute('ramp_down_sp', value)
      end

      # @return [<:running,:ramping,:holding,:overloaded,:stalled>] the current state flags
      def current_states
        read_attribute('state').split(' ').map { |state| state.to_sym }
      end

      def running?
        current_states.include?(:running)
      end

      def ramping?
        current_states.include?(:ramping)
      end

      def holding?
        current_states.include?(:holding)
      end

      def overloaded?
        current_states.include?(:overloaded)
      end

      def stalled?
        current_states.include?(:stalled)
      end

      def stopped?
        !running?
      end

      # @return [<Symbol>] a list of stop actions available for the motor
      def stop_actions
        @stop_actions ||= read_attribute('stop_actions').split(' ').map(&:to_sym)
      end

      # @return [Symbol] the current action when command `stop` is sent
      def stop_action
        read_attribute('stop_action').to_sym
      end

      # Sets the behavior when the `stop` command is sent to the motor
      #
      # @param value [Symbol] must be included in #stop_actions
      #
      # @raise [ArgumentError] when value is not included in #stop_actions
      def stop_action=(value)
        raise(ArgumentError, "given value #{value} is invalid") unless stop_actions.include?(value)

        write_attribute('stop_action', value)
      end

      # @return [Integer] the number of milliseconds the motor will run when using the `run-timed` command
      def time_setpoint
        read_attribute('time_sp').to_i
      end

      # Sets the time the motor will run when using the `run-timed` command
      #
      # @param value [Integer] in milliseconds. Must not be negative.
      #
      # @raise [ArgumentError] when value is negative
      def time_setpoint=(value)
        raise(ArgumentError, "given value #{value} is invalid") if value.negative?

        write_attribute('time_sp', value)
      end

      # Runs the motor forever (until it is stopped)
      #
      # @param speed [Integer] the desired speed in tacho counts per second. When not given, the current #speed_setpoint is used
      def run!(speed = nil)
        self.speed_setpoint = speed if speed

        self.command = :'run-forever'
      end

      # Runs the motor for the given time
      #
      # @param time [Integer] time the motor shall run in milliseconds
      def run_for!(time)
        self.time_setpoint = time

        self.command = :'run-timed'
      end

      # Runs the motor until the given absolute position is reached
      # 
      # @param position [Integer] in tacho counts
      def run_to_absolute_position!(position)
        self.position_setpoint = position

        self.command = :'run-to-abs-pos'
      end

      # Runs the motor until the motor has passed the given number of counts
      #
      # @param counts [Integer]
      def run_by!(counts)
        self.position_setpoint = counts

        self.command = :'run-to-rel-pos'
      end

      # Runs the motor until it is stopped
      #
      # @param duty_cycle [Integer, nil] the (relative) power to run the motor. Must be within -100..100. When `nil`,
      #   the current #duty_cycle_setpoint is used
      def run_directly!(duty_cycle = nil)
        self.duty_cycle_setpoint = duty_cycle if duty_cycle

        self.command = :'run-direct'
      end

      # Stops the motor
      def stop!
        self.command = :stop
      end

      # Resets the counters and stops the motor
      def reset!
        self.command = :reset
      end
    end
  end
end
