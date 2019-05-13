module Ev3
  module TestTool
    TEST_DIR = '/tmp/mruby-ev3-test'

    module Ev3TestMod
      def sysfs_class_path
        Ev3TestTool::TEST_DIR
      end
    end
    
    class TestDeviceDir
      attr_reader :path

      def initialize(path, initial_objects = nil)
        @path = path

        if initial_objects
          initial_objects.each { |attribute, value| self[attribute] = value }
        end
      end

      def [](attribute)
        File.read(path_to(attribute))
      end

      def []=(attribute, value)
        $stderr.puts "Writing #{value} to #{attribute}"

        File.open(path_to(attribute), 'w') do |file|
          file << value
        end
      end

      def bin_write(attribute, value)
        File.open(path_to(attribute), 'wb') do |file|
          file << value
        end
      end

      def teardown
        Dir.rmdir(path)
      end

      private

      def path_to(attribute)
        File.join(path, attribute.to_s)
      end
    end

    class << self
      def setup
        Dir.mkdir(TEST_DIR)
        ::Ev3.prepend(Ev3TestMod)
      end

      def add_device(path, initial_objects = nil)
        TestDeviceDir.new(File.join(TEST_DIR, path), initial_objects)
      end

      def teardown
        Dir.rmdir(TEST_DIR)
      end
    end
  end
end

assert('Ev3 TEST SETUP') { ::Ev3::TestTool.setup }

assert('Ev3') do
  assert_equal('Module', Ev3.class)

  assert_true(true)

  assert('.sensors') { skip }
  assert('.motors') { skip }
  assert('.sound') { skip }
  assert('.leds') { skip }
  assert('.buttons') { skip }
end

assert('Ev3::LEDs::BuiltIn') do
  device_node = Ev3::TestTool.add_device('leds')

  led_number = 0
  led = Ev3::LEDs::BuiltIn.new(device_node.path, led_number)

  assert('#device_node_for') do
    assert_equal(File.join(device_node.path, "led#{led_number}:green:brick-status"), led.device_node_for(:green))
  end
end

assert('Ev3::Motors::Generic') do
  assert_true(Ev3::Device < Ev3::Motors::Generic)

  device_node = ::Ev3::TestTool.add_device('generic_motor', max_speed: 1000, stop_actions: %w(coast brake hold))

  motor = Ev3::Motors::Generic.new(device_node.path)

  assert('#counts_per_rotation') do
    device_node[:counts_per_rotation] = 1200
    assert_equal('1200', motor.counts_per_rotation)
  end

  assert('#duty_cycle') do
    device_node[:duty_cycle] = 100
    assert_equal(100, motor.duty_cycle)
  end

  assert('#duty_cycle_setpoint') do
    device_node[:duty_cycle_sp] = 80
    assert_equal(80, motor.duty_cycle_setpoint)
  end

  assert('#duty_cycle_setpoint=') do
    assert_equal(50, motor.duty_cycle_setpoint = 50)
    assert_equal('50', device_node[:duty_cycle_sp])

    assert_equal(-50, motor.duty_cycle_setpoint = -50)
    assert_equal('-50', device_node[:duty_cycle_sp])

    assert_raise(ArgumentError) { motor.duty_cycle_setpoint = -101 }
    assert_raise(ArgumentError) { motor.duty_cycle_setpoint = 101 }
  end

  assert('#polarity') do
    device_node[:polarity] = 'normal'
    assert_equal(:normal, motor.polarity)
  end

  assert('#polarity=') do
    assert_equal(:inversed, motor.polarity = :inversed)
    assert_equal('inversed', device_node[:polarity])
    assert_equal(:normal, motor.polarity = :normal)
    assert_equal('normal', device_node[:polarity])

    assert_raise(ArgumentError) { motor.polarity = :invalid }
  end

  assert('#position') do
    device_node[:position] = 12345
    assert_equal(12345, motor.position)
  end

  assert('#position=') do
    assert_equal(987, motor.position = 987)
    assert_equal('987', device_node[:position])
  end

  assert('#max_speed') do
    device_node[:max_speed] = 1000
    assert_equal(1000, motor.max_speed)
  end

  assert('#position_setpoint') do
    device_node[:position_sp] = 120
    assert_equal(120, motor.position_setpoint)
  end

  assert('#position_setpoint=') do
    assert_equal(100, motor.position_setpoint = 100)
    assert_equal('100', device_node[:position_sp])
  end

  assert('#speed') do
    device_node[:speed] = 500
    assert_equal(500, motor.speed)
  end

  assert('#speed_setpoint') do
    device_node[:speed_sp] = 400
    assert_equal(400, motor.speed_setpoint)
  end

  assert('#speed_setpoint=') do
    assert_equal(300, motor.speed_setpoint = 300)
    assert_equal('300', device_node[:speed_sp])

    assert_raise(ArgumentError) { motor.speed_setpoint = -1001 }
    assert_raise(ArgumentError) { motor.speed_setpoint = 1001 }
  end

  assert('#ramp_up_setpoint') do
    device_node[:ramp_up_sp] = 50
    assert_equal(50, motor.ramp_up_setpoint)
  end

  assert('#ramp_up_setpoint=') do
    assert_equal(100, motor.ramp_up_setpoint = 100)
    assert_equal('100', device_node[:ramp_up_sp])

    assert_raise(ArgumentError) { motor.ramp_up_setpoint = -1 }
  end

  assert('#ramp_down_setpoint') do
    device_node[:ramp_down_sp] = 55
    assert_equal(55, motor.ramp_down_setpoint)
  end

  assert('#ramp_down_setpoint=') do
    assert_equal(105, motor.ramp_down_setpoint = 105)
    assert_equal('105', device_node[:ramp_down_sp])

    assert_raise(ArgumentError) { motor.ramp_down_setpoint = -1 }
  end

  assert('#current_states') do
    device_node[:state] = 'running ramping holding overloaded stalled'
    assert_same([:running, :ramping, :holding, :overloaded, :stalled], motor.current_states)
  end

  assert('#running?') do
    device_node[:state] = 'running'
    assert_true(motor.running?)

    device_node[:state] = ''
    assert_false(motor.running?)
  end

  assert('#ramping?') do
    device_node[:state] = 'running ramping stalled'
    assert_true(motor.ramping?)

    device_node[:state] = 'running stalled'
    assert_false(motor.ramping?)
  end

  assert('#holding?') do
    device_node[:state] = 'holding'
    assert_true(motor.holding?)

    device_node[:state] = ''
    assert_false(motor.holding?)
  end

  assert('#overloaded?') do
    device_node[:state] = 'overloaded'
    assert_true(motor.overloaded?)

    device_node[:state] = ''
    assert_false(motor.overloaded?)
  end

  assert('#stalled?') do
    device_node[:state] = 'stalled'
    assert_true(motor.stalled?)

    device_node[:state] = ''
    assert_false(motor.stalled?)
  end

  assert('#stopped?') do
    device_node[:state] = ''
    assert_true(motor.stopped?)

    device_node[:state] = 'running'
    assert_false(motor.stopped?)
  end

  assert('#stop_actions') do
    assert_same(%i(coast brake hold), motor.stop_actions)
  end

  assert('#stop_action') do
    device_node[:stop_action] = 'coast'
    assert_equal(:coast, motor.stop_action)
  end

  assert('#stop_action=') do
    assert_equal(:hold, motor.stop_action = :hold)
    assert_equal('hold', device_node[:stop_action])

    assert_raise(ArgumentError) { motor.stop_action = :invalid }
  end

  assert('#time_setpoint') do
    device_node[:time_sp] = 250
    assert_equal(250, motor.time_setpoint)
  end

  assert('#time_setpoint=') do
    assert_equal(500, motor.time_setpoint = 500)
    assert_equal('500', device_node[:time_sp])

    assert_raise(ArgumentError) { motor.time_setpoint = -1 }
  end

  assert('#run!') do
    device_node[:speed_sp] = 1000
    
    motor.run!
    assert_equal('1000', device_node[:speed_sp])
    assert_equal('run-forever', device_node[:command])

    motor.run!(500)
    assert_equal('500', device_node[:speed_sp])
    assert_equal('run-forever', device_node[:command])
  end

  assert('#run_for!') do
    motor.run_for!(123)

    assert_equal('123', device_node[:time_sp])
    assert_equal('run-timed', device_node[:command])
  end

  assert('#run_to_absolute_position!') do
    motor.run_to_absolute_position!(1024)

    assert_equal('1024', device_node[:position_sp])
    assert_equal('run-to-abs-pos', device_node[:command])
  end

  assert('#run_by!') do
    motor.run_by!(42)

    assert_equal('42', device_node[:position_sp])
    assert_equal('run-to-rel-pos', device_node[:command])
  end

  assert('#run_directly!') do
    device_node[:duty_cycle_sp] = 100

    motor.run_directly!
    assert_equal('100', device_node[:duty_cycle_sp])
    assert_equal('run-direct', device_node[:command])

    device_node[:command] = ''

    motor.run_directly!(-50)
    assert_equal('-50', device_node[:duty_cycle_sp])
    assert_equal('run-direct', device_node[:command])
  end

  assert('#stop!') do
    motor.stop!
    assert_equal('stop', device_node[:command])
  end

  assert('#reset!') do
    motor.reset!
    assert_equal('reset', device_node[:command])
  end
end

assert('Ev3::Sensors::Color') do
  assert_true(Ev3::Sensors::Generic > Ev3::Sensors::Color)
end

assert('Ev3::Sensors::Generic') do
  assert_true(Ev3::Device > Ev3::Sensors::Generic)

  device_node = ::Ev3::TestTool.add_device('generic_sensor', modes: 'TEST ANOTHER_TEST', num_values: 2)

  sensor = Ev3::Sensors::Generic.new(device_node.path)

  assert('#bin_data') do
    data = "\x00\x01\x02"
    device_node.bin_write(:bin_data, data)

    assert_equal(data, sensor.bin_data)
  end

  assert('#bin_data_format') do
    device_node[:bin_data_format] = 'S16'
    assert_equal('S16', sensor.bin_data_format)
  end

  assert('#decimals') do
    device_node[:decimals] = 0
    assert_equal(0, sensor.decimals)
  end

  assert('#mode') do
    device_node[:mode] = 'TEST'
    assert_equal('TEST', sensor.mode)
  end

  assert('#mode=') do
    sensor.mode = 'ANOTHER_TEST'
    assert_equal('ANOTHER_TEST', device_node[:mode])

    assert_raise(ArgumentError) do
      sensor.mode = 'INVALID'
    end
  end

  assert('#modes') do
    assert_same(['TEST', 'ANOTHER_TEST'], sensor.modes)
  end

  assert('#num_values') do
    assert_equal(2, sensor.num_values)
  end

  assert('#poll_ms') do
    device_node[:poll_ms] = 500
    assert_equal(500, sensor.poll_ms)

    device_node[:poll_ms] = ''
    assert_nil(sensor.poll_ms)
  end

  assert('#units') do
    device_node[:units] = 'cm'
    assert_equal('cm', sensor.units)
  end

  assert('#text_value') do
    device_node[:text_value] = 'some text'
    assert_equal('some text', sensor.text_value)
  end

  assert('#value') do
    device_node[:value0] = 100
    device_node[:value1] = 200

    assert_equal(100, sensor.value(0))
    assert_equal(200, sensor.value(1))

    assert_raise(ArgumentError) { sensor.value(3) }

    device_node[:decimals] = 2
    assert_same(Rational(100/100), sensor.value(0))
  end

  assert('#formatted_value') do
    device_node[:decimals] = 2
    device_node[:value0] = 123
    device_node[:units] = 'cm'

    assert_equal('1.23 cm', sensor.formatted_value(0))
  end

  device_node.teardown
end

assert('Ev3::Sensors::Gyro') do
  assert_true(Ev3::Sensors::Generic > Ev3::Sensors::Gyro)
end

assert('Ev3::Sensors::Infrared') do
  assert_true(Ev3::Sensors::Generic > Ev3::Sensors::Infrared)
end

assert('Ev3::Sensors::Touch') do
  assert_true(Ev3::Sensors::Generic > Ev3::Sensors::Touch)

  device = ::Ev3::TestTool.add_device('touch_sensor')
  sensor = Ev3::Sensors::Touch.new(device.path)
  
  assert('#released?') do
    device[:value0] = 0
    assert_true(sensor.released?)

    device[:value0] = 1
    assert_false(sensor.released?)
  end

  assert('#pressed?') do
    device[:value0] = 0
    assert_false(sensor.pressed?)
    
    device[:value0] = 1
    assert_true(sensor.pressed?)
  end

  device.teardown
end

assert('Ev3::Sensors::UltraSonic') do
  assert_true(Ev3::Sensors::Generic > Ev3::Sensors::UltraSonic)
end

assert('Ev3 TEST TEARDOWN') { ::Ev3::TestTool.teardown }
