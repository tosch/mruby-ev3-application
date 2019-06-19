LEFT_MOTOR = Ev3.motors[:outB]
RIGHT_MOTOR = Ev3.motors[:outC]
PEN_MOTOR = Ev3.motors[:outA]
GYRO = Ev3.sensors[:in4]

DISTANCE_PER_ROTATION = 173

# ROBOT = Ev3::MovementController.new(LEFT_MOTOR, RIGHT_MOTOR, gyro: GYRO, distance_per_rotation: DISTANCE_PER_ROTATION)

SPEED = 7

LEFT_MOTOR.stop_action = :hold
RIGHT_MOTOR.stop_action = :hold

# Reset Gyro
GYRO.mode = 'GYRO-CAL'
GYRO.mode = 'GYRO-ANG'

class PenControl
  attr_reader :motor

  def initialize(motor)
    @motor = motor

    motor.speed_setpoint = (motor.max_speed / 3).round
  end

  def up(wait: true)
    motor.run_to_absolute_position!(0)

    wait_for_stop if wait
  end

  def down(wait: true)
    motor.run_to_absolute_position!(40)

     wait_for_stop if wait
  end

  private

  def wait_for_stop
    nil while motor.running?
  end
end

class Plotter
  attr_reader :left_motor, :right_motor, :gyro, :pen, :robot

  def initialize(left_motor, right_motor, gyro, pen, distance_per_rotation)
    @left_motor = left_motor
    @right_motor = right_motor
    @gyro = gyro
    @pen = pen

    @robot = Ev3::MovementController.new(left_motor, right_motor, gyro: gyro, distance_per_rotation: distance_per_rotation)
  end

  # Each letter begins at the lower left, pointing to the right
  def draw(char)
    case char
    when 'A'
      draw_A
    when 'H'
      draw_H
    when 'Y'
      draw_Y
    when 'E'
      draw_E
    when 'U'
      draw_U
    when 'R'
      draw_R
    when 'K'
      draw_K
    when 'O'
      draw_O
    else
      raise "Do not know how to draw '#{char}'"
    end
  end

  def draw_ruby
    turn_by(-127)
    pen.down
    forward_by(150)
    turn_by(75)#74)
    forward_by(50)
    turn_by(54)#53)
    forward_by(120)
    turn_by(54)#53)
    forward_by(50)
    turn_by(75)#74)
    forward_by(150)
    pen.up
    turn_by(107)#106)
    forward_by(150)
    turn_by(128)#127)
    pen.down
    forward_by(180)
    pen.up
    forward_by(-120)
    turn_by(77)#76)
    pen.down
    forward_by(124)
    pen.up
    turn_by(-151) # -152)
    pen.down
    forward_by(124)
    turn_by(-50) #-51)
    forward_by(50)
    turn_by(-105) # -106)
    forward_by(50)
    turn_by(107)#106)
    forward_by(50)
    pen.up
    turn_by(128)#127)
    forward_by(120)
    turn_by(128)#127)
    pen.down
    forward_by(50)
    pen.up
    turn_by(-22) # -23)
    forward_by(124)
    turn_by(-105) # -106)
    forward_by(110)
  end

  def draw_square_anti_clockwise(length)
    pen.down
    forward_by(length)
    turn_by(-90)
    forward_by(length)
    turn_by(-90)
    forward_by(length)
    turn_by(-90)
    forward_by(length)
    pen.up
    turn_by(-90)
    forward_by(length + 20)
  end

  def draw_square_clockwise(length)
    turn_by(-90)
    pen.down
    4.times do
      forward_by(length)
      turn_by(90)
    end
    pen.up
    turn_by(90)
    forward_by(length + 20)
  end

  def forward_by(distance)
    puts "Forward by #{distance}"
    robot.forward_by(distance, SPEED)
    robot.wait_for_stop
  end

  def turn_by(angle, turn_speed = nil, backwards = false)
    turn_speed ||= (angle < 0) ? -100 : 100

    puts "Turn by #{angle} (turn speed #{turn_speed}) #{backwards ? 'backwards' : ''}"

    robot.turn_by(angle, backwards ? -SPEED : SPEED, turn_speed)
  end

  private

  def draw_A
    # upwards stroke
    turn_by(-67)#-68)
    pen.down
    forward_by(108)
    turn_by(-43)#-44)

    # downwards stroke
    forward_by(-108)
    pen.up

    # upwards to horizontal stroke
    forward_by(54)
    turn_by(-67)#-68)

    # horizontal stroke
    pen.down
    forward_by(40)
    pen.up

    # to the next char
    forward_by(-40)
    turn_by(-111)#-112)
    forward_by(54)
    turn_by(-67)#-68)
    forward_by(20)
  end

  def draw_H
    # left vertical stroke
    turn_by(-89)#-90)
    pen.down
    forward_by(100)
    pen.up
    forward_by(-50)
    turn_by(90)

    # horizontal stroke
    pen.down
    forward_by(50)
    pen.up
    turn_by(-89)#-90)
    forward_by(50)

    # right vertical stroke
    pen.down
    forward_by(-100)
    pen.up

    # to the next char
    turn_by(90)
    forward_by(20)
  end

  def draw_Y
    # stroke from down left to up right
    turn_by(-68)#-69)
    pen.down
    forward_by(117)
    pen.up
    forward_by(-58)
    turn_by(-61)#-62)

    # stroke from middle to upper left
    pen.down
    forward_by(58)
    pen.up

    # to the next char
    forward_by(-117)
    turn_by(121)
    forward_by(20)
  end

  def draw_E
    # lower stroke
    forward_by(50)
    pen.down
    forward_by(-50)
    turn_by(-89)#-90)

    # upwards stroke
    forward_by(100)
    turn_by(90)

    # upper stroke
    forward_by(50)
    pen.up

    # back to the upwards stroke
    forward_by(-50)
    turn_by(90)
    forward_by(50)
    turn_by(-89)#-90)

    # middle stroke
    pen.down
    forward_by(40)
    pen.up

    # to the next char
    forward_by(-40)
    turn_by(90)
    forward_by(50)
    turn_by(-89)#-90)
    forward_by(70)
  end

  def draw_U
    # we have to move to the upper left
    turn_by(-89)#-90)
    forward_by(100)

    # begin the downwards slope
    pen.down
    forward_by(-59)#-60)
    # the U bend
    turn_by(180, 75, true)
    # upwards
    forward_by(-70) # needs to be a bit more than on the downwards slope
    pen.up

    # to the next char
    forward_by(100)
    turn_by(-89)#-90)
    forward_by(20)
  end

  def draw_R
    turn_by(-89)#-90)
    # draw the upwards stroke
    pen.down
    forward_by(100)

    # the bend
    turn_by(90)
    forward_by(10)
    turn_by(180, 80)
    forward_by(10)

    # the lower stroke
    turn_by(-134)#-135)
    forward_by(65)
    pen.up

    # to the next char
    turn_by(-44)#-45)
    forward_by(20)
  end

  def draw_K
    turn_by(-89)#-90)
    # the straight upwards stroke
    pen.down
    forward_by(100)
    pen.up
    forward_by(-50)

    # stroke upwards right
    turn_by(37)
    pen.down
    forward_by(55)
    pen.up
    forward_by(-55)
    turn_by(106)

    # stroke downwards right
    pen.down
    forward_by(55)
    pen.up

    # to the next char
    turn_by(-71)#-74)
    forward_by(20)
  end

  def draw_O
    forward_by(30)
    pen.down
    # go full circle
    turn_by(-360, -70)
    pen.up

    # to the next char
    turn_by(2)
    forward_by(50)
  end
end

plotter = Plotter.new(LEFT_MOTOR, RIGHT_MOTOR, GYRO, PenControl.new(PEN_MOTOR), DISTANCE_PER_ROTATION)

plotter.draw_ruby

plotter.forward_by(40)

'AHOY'.each_char { |char| plotter.draw(char) }

plotter.turn_by(-23)#-24)
plotter.forward_by(-370)#-371)
plotter.turn_by(23)#24)

'EURUKO'.each_char { |char| plotter.draw(char) }

# plotter.draw_square_anti_clockwise(100)
