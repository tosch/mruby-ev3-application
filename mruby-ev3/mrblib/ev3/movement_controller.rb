module Ev3
  # Helper class for controlling the movements of a robot
  class MovementController
    # @return [Range] Allowed values for `direction` arguments
    DIRECTION_RANGE = (-100..100).freeze
    # @return [Range] Allowed values for `power` arguments
    POWER_RANGE = (-100..100).freeze

    attr_reader :left_motor, :right_motor, :inverse_left, :inverse_right, :max_speed, :counts_per_rotation
    attr_accessor :distance_per_rotation, :gyro

    # @param left_motor [Ev3::Motors::Generic] The left motor
    # @param right_motor [Ev3::Motors::Generic] The right motor
    # @param inverse_left [true, false] Set to true to inverse the polarity of the left motor. Defaults to false.
    # @param inverse_right [true, false] Set to true to inverse the polarity of the right motor. Defaults to false.
    # @param gyro [Ev3::Sensors::Gyro, nil] An instance of a gyro sensor which will be used to drive turns by angle.
    #   Defaults to nil. Must be set for using #turn_by
    # @param distance_per_rotation [Integer, nil] The distance (in mm) the robot drives on one complete rotation of the
    #   motor. Defaults to nil. Must be set for using #forward_by.
    #   Please remember that one rotation of the motor may not be one rotation of the wheels when there are gears or
    #   other transmissions between motor and wheel.
    #   Helpful hint: The circumference of a wheel is the product of the diameter and PI. The wheels in the
    #   standard EV3 Education box have a diameter of 56 mm, so one rotation will yield a distance of 176 mm.
    #
    # @raise [ArgumentError] When the left and the right motor have different counts per rotation
    #   (they must be of the same type)
    def initialize(left_motor, right_motor, inverse_left: false, inverse_right: false, gyro: nil, distance_per_rotation: nil)
      @left_motor = left_motor
      @right_motor = right_motor
      @inverse_left = inverse_left
      @inverse_right = inverse_right
      @gyro =  gyro
      @distance_per_rotation = distance_per_rotation

      left_motor.polarity = inverse_left ? :inversed : :normal
      right_motor.polarity = inverse_right ? :inversed : :normal

      @max_speed = motors.map(&:max_speed).min

      @counts_per_rotation = left_motor.counts_per_rotation
      raise(ArgumentError, "left and right motor must be of same type") if right_motor.counts_per_rotation != @counts_per_rotation
    end

    # Move the robot with the given power using the given direction.
    #
    # @param power [-100..100] The relative speed the robot shall move. Negative values will make the robot drive
    #   backwards. A value of zero will stop the robot.
    # @param direction [-100..100] The direction for the movement. A value of 0 will move the robot straightforward.
    #   Negative values will turn the robot to the left, positive values to the right.
    # @param duration [Integer, nil] When set, the robot will stop moving after the given number of miliseconds.
    #   Defaults to nil.
    #
    # @raise [ArgumentError] when the given power is not within -100..100 or the given direction is not within -100..100
    def go(power, direction, duration: nil)
      raise(ArgumentError, "Given power #{power} is not within allowed range -100..100.") unless POWER_RANGE.include?(power)
      raise(ArgumentError, "Given direction #{direction} is not within allowed range -100..100.") unless DIRECTION_RANGE.include?(direction)

      return stop if power.zero?

      direction = Rational(direction, 1)

      full_speed = power_to_speed(power)

      left_motor.speed_setpoint = left_speed_for(full_speed, direction)
      right_motor.speed_setpoint = right_speed_for(full_speed, direction)

      if duration
        left_motor.run_for!(duration)
        right_motor.run_for!(duration)
      else
        left_motor.run!
        right_motor.run!
      end

      self
    end

    # Moves the robot straightforward for a given distance.
    #
    # Please note that this method does not block, ie., the code execution will continue right after sending the
    # `run` commands to the motors. If you want to block the execution until the robot has finished its movement,
    # use the #wait_for_stop method.
    #
    # @param distance [Integer] distance to go forward in mm
    # @param power [Integer] the relative power in percent of the maximum speed. Set to a negative value to drive backwards.
    #
    # @raise [ArgumentError] when the MovementController has not been initialized with `:distance_per_rotation`.
    def forward_by(distance, power)
      raise(ArgumentError, "#{self.class.name} has to be initialized with :distance_per_rotation") unless distance_per_rotation
      return stop if power.zero?

      left_motor.speed_setpoint = right_motor.speed_setpoint = power_to_speed(power).round

      distance = Rational(distance, 1) unless distance.is_a?(Rational)
      counts = (distance / distance_per_count).round

      left_motor.run_by!(counts) && right_motor.run_by!(counts)

      self
    end

    # Turns the robot by the given angle using a gyro sensor.
    #
    # This method blocks until the given angle has been reached. You can pass a block that will be executed between
    # each check. Make sure to not do complex stuff within the block, otherwise the robot might turn far too wide.
    #
    # @param angle [Integer] The angle by which the robot should be turned. Negative values turn the robot to the
    #   left, positive values to the right.
    # @param power [-100..100] The relative speed the robot should drive in percent of the maximum speed.
    # @param direction [-100..-1,1..100] The "turn factor". Negative values turn the robot to the left, positive
    #   numbers to the right. The larger the absolute of the number, the more the robot will turn on the spot. Must not
    #   be zero. Must have the same sign as `angle`
    #
    # @raise [ArgumentError] When direction is zero or angle and direction have different signs or when the
    #   MovementController has not been initialized with `:gyro`.
    def turn_by(angle, power, direction)
      raise(ArgumentError, 'direction must not be zero, otherwise the robot would not turn') if direction.zero?
      raise(ArgumentError, "#{self.class.name} must be initialized with :gyro for this method") unless gyro
      raise(ArgumentError, "direction and angle must have the same sign") unless (angle.negative? && direction.negative?) || (angle.positive? && direction.positive?)

      gyro.mode = "GYRO-ANG"
      initial_angle = gyro.value(0)

      target_angle = if direction.negative?
          initial_angle - angle
        else
          initial_angle + angle
        end
      target_angle = if power.negative?
        initial_angle - angle
      else
        initial_angle + angle
      end

      anti_clockwise = direction.negative? || power.negative?


      go(power, direction)

      block_given? ? yield : nil while direction.negative? ? target_angle <= current_angle : target_angle >= current_angle
      loop do
        yield if block_given?

        remaining_distance = remaining_angle_distance_for(target_angle, anti_clockwise)

        if remaining_distance <= 5 && remaining_distance > 0
          go(power.negative? ? -1 : 1, direction)
        elsif remaining_distance <= 0
          stop
          break
        end
      end
      remaining = remaining_angle_distance_for(target_angle, anti_clockwise)
      if remaining < 0
        go(power.negative? ? 1 : -1, direction)
        loop do
          remaining = remaining_angle_distance_for(target_angle, anti_clockwise)
          if remaining >= 0
            stop
            break
          end
        end
      end

      self
    end

    # Stops any movement
    def stop
      left_motor.stop!
      right_motor.stop!

      self
    end

    # Blocks execution until the robot has stopped.
    #
    # You can pass a block to this method which will be executed between each check if the robot is still running.
    # The block won't be called if the robot is stopped from the beginning.
    def wait_for_stop
      block_given? ? yield : nil while motors.any?(&:running?)
    end

    private

    def power_to_speed(power)
      Rational(power * max_speed, 100)
    end

    def left_speed_for(full_speed, direction)
      speed = if (direction <=> 0) == -1
          full_speed - ((direction * Rational(-2, 1) * full_speed) / Rational(100, 1))
        else
          full_speed
        end

      speed.round
    end

    def right_speed_for(full_speed, direction)
      speed = if (direction <=> 0) == 1
          full_speed - ((direction * Rational(2, 1) * full_speed) / Rational(100, 1))
        else
          full_speed
        end

      speed.round
    end

    def motors
      [left_motor, right_motor]
    end

    def distance_per_count
      @distance_per_count ||= Rational.new(distance_per_rotation, counts_per_rotation)
    end

    def current_angle
      gyro.value(0)
    end

    def remaining_angle_distance_for(target_angle, anti_clockwise = false)
      if anti_clockwise
        current_angle - target_angle
      else
        target_angle - current_angle
      end
    end
  end
end
