# Define the motors we use
MOTOR_LEFT = Ev3.motors[:outB]
MOTOR_RIGHT = Ev3.motors[:outC]

# Define the sensors we use
US_SENSOR = Ev3.sensors[:in1]
COLOR_SENSOR = Ev3.sensors[:in3]
GYRO_SENSOR = Ev3.sensors[:in4]

# Set the sensor modes
US_SENSOR.mode = 'US-DIST-CM'
COLOR_SENSOR.mode = 'COL-REFLECT'
GYRO_SENSOR.mode = 'GYRO-ANG'

# Monkey-patching SimpleHttpServer to include request object in the request environment
module SimpleHttpServerExtension
  private

  def request_to_env(io, req)
    super.merge('request' => req)
  end
end
SimpleHttpServer.prepend(SimpleHttpServerExtension)

# Helper class to store the current movement settings
class MovementState
  attr_reader :controller, :power, :direction

  def initialize
    @power = 0
    @direction = 0
    @controller = Ev3::MovementController.new(::MOTOR_LEFT, ::MOTOR_RIGHT)
  end

  def power=(value)
    @power = value

    send_go

    power
  end

  def direction=(value)
    @direction = value

    send_go

    direction
  end

  private

  def send_go
    controller.go(power, direction)
  end
end

movement_state = MovementState.new

# The application that will be run by SimpleHttpServer
APPLICATION = Shelf::Builder.app do
  use Shelf::CommonLogger
  use Shelf::CatchError

  get '/' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'text/html; charset=utf-8'

    run ->(env) do
      body_string = <<"@HTML"
<!DOCTYPE html>
<html>
  <head>
    <title>EV3 Remote Control</title>
    <script src="https://code.jquery.com/jquery-3.4.0.min.js"></script>
    <style>
      body {
        background: #20262E;
        padding: 20px;
        font-family: Helvetica, sans-serif;
      }

      h1 {
        color: #eee;
      }

      .column {
        float: left;
        width: 50%;
      }

      #content:after {
        content: "";
        display: table;
        clear: both;
      }

      #control {
        width: 400px;
        height: 400px;
        background-color: #eee;
        background-image:
          linear-gradient(black 1px, transparent 1px),
          linear-gradient(90deg, black 1px, transparent 1px);
        background-size: 200px 200px, 200px 200px;
        background-position: 0 0, 0 0;
      }

      #pointer {
        position: relative;
        top: 197px;
        left: 197px;
        width: 7px;
        height: 7px;
        background-color: #000;
      }

      dl#info {
        display: flex;
        flex-flow: row wrap;
        width: 400px;
        background-color: #aaa;
        padding: 10px;
        margin-left: 10px;
      }

      dl#info dt {
        flex-basis: 45%;
        text-align: right;
        padding: 0 5px;
      }

      dl#info dd {
        flex-basis: 45%;
        flex-grow: 1;
        margin: 0;
        padding: 0 5px;
      }
    </style>
    <script>
      $(function() {
        $.Pointer = function (element) {
          this.element = element;
          this.power = 0;
          this.direction = 0;
          this.draw();

          this.element.on('changepower', function(e, pointer) { pointer.draw(); });
          this.element.on('changedirection', function(e, pointer) { pointer.draw(); });
          this.element.on('reset', function(e, pointer) {
            pointer.draw();
            pointer.element.trigger('changepower', pointer);
            pointer.element.trigger('changedirection', pointer);
          });
        };

        $.Pointer.prototype.draw = function() {
          this.element.css('left', (197 + (2 * this.direction)) + 'px');
          this.element.css('top', (197 - (2 * this.power)) + 'px');
        };

        $.Pointer.prototype.changePower = function(step) {
          var result = this.power + step;

          if (result > 100) result = 100;
          if (result < -100) result = -100;

          this.power = result;

          this.element.trigger('changepower', this);
        };

        $.Pointer.prototype.changeDirection = function(step) {
          var result = this.direction + step;

          if (result > 100) result = 100;
          if (result < -100) result = -100;

          this.direction = result;

          this.element.trigger('changedirection', this);
        };

        $.Pointer.prototype.reset = function() {
          this.power = 0;
          this.direction = 0;

          this.element.trigger('reset', this);
        }

        var pointerElement = $('#pointer');
        var pointer = new $.Pointer(pointerElement);

        $(document).keydown(function(event) {
          switch(event.key) {
            case " ":
              pointer.reset();
              break;
            case "ArrowUp":
              pointer.changePower(event.shiftKey ? 5 : 1);
              break;
            case "ArrowDown":
              pointer.changePower(event.shiftKey ? -5 : -1);
              break;
            case "ArrowLeft":
              pointer.changeDirection(event.shiftKey ? -5 : -1);
              break;
            case "ArrowRight":
              pointer.changeDirection(event.shiftKey ? 5 : 1);
              break;
            default:
              return;
          }

          event.preventDefault();
        });

        pointerElement.on('changepower', function(e, pointer) {
          $.post('/power', '' + pointer.power);
          $('#power-value').text(pointer.power);
        });

        pointerElement.on('changedirection', function(e, pointer) {
          $.post('/direction', '' + pointer.direction);
          $('#direction-value').text(pointer.direction);
        });

        setInterval(
          function() { $.get('/us-distance').done(function(result) { $('#us-dist-value').text(result) }); },
          700
        );
        setInterval(
          function() { $.get('/gyro-angle').done(function(result) { $('#gyro-ang-value').text(result) }); },
          750
        );
        setInterval(
          function() { $.get('/color-reflect').done(function(result) { $('#col-reflect-value').text(result) }); },
          800
        );
      });
    </script>
  </head>
  <body>
    <h1>EV3 Remote Control</h1>
    <div id="content">
      <div id="control" class="column"><div id="pointer"></div></div>
      <dl id="info" class="column">
        <dt>Power</dt>
        <dd id="power-value">0</dd>
        <dt>Direction</dt>
        <dd id="direction-value">0</dd>
        <dt>US-DIST-CM</dt>
        <dd id="us-dist-value"></dd>
        <dt>GYRO-ANG</dt>
        <dd id="gyro-ang-value"></dd>
        <dt>COL-REFLECT</dt>
        <dd id="col-reflect-value"></dd>
      </dl>
    </div>
  </body>
</html>
@HTML

      [
        200,
        {},
        [body_string]
      ]
    end
  end

  get '/sensors' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'application/json; charset=utf-8'

    run ->(_env) do
      [
        200,
        {},
        [
          {
            sensors: Ev3.sensors.map do |address, sensor|
              {
                address: address,
                driver_name: sensor.driver_name,
                mode: sensor.mode,
                values: sensor.values,
                units: sensor.units
              }
            end
          }.to_json
        ]
      ]
    end
  end

  get '/motors' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'application/json; charset=utf-8'

    run ->(_env) do
      [
        200,
        {},
        [
          {
            motors: Ev3.motors.map do |address, motor|
              {
                address: address,
                driver_name: motor.driver_name,
                duty_cycle: motor.duty_cycle,
                polarity: motor.polarity,
                position: motor.position,
                speed: motor.speed,
                current_states: motor.current_states
              }
            end
          }.to_json
        ]
      ]
    end
  end

  get '/board-info' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'application/json; charset=utf-8'

    run ->(_env) do
      [
        200,
        {},
        [
          {
            hardware_revision: Ev3.board_info.hardware_revision,
            model: Ev3.board_info.model,
            rom_revision: Ev3.board_info.rom_revision,
            serial_number: Ev3.board_info.serial_number
          }.to_json
        ]
      ]
    end
  end

  get '/us-distance' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'text/plain; charset=utf-8'

    run ->(env) do
      [200, {}, [::US_SENSOR.formatted_value(0)]]
    end
  end

  get '/gyro-angle' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'text/plain; charset=utf-8'

    run ->(env) do
      [200, {}, [::GYRO_SENSOR.formatted_value(0)]]
    end
  end

  get '/color-reflect' do
    use Shelf::ContentLength
    use Shelf::ContentType, 'text/plain; charset=utf-8'

    run ->(env) do
      [200, {}, [::COLOR_SENSOR.formatted_value(0)]]
    end
  end

  post '/power' do
    run ->(env) do
      power = env['request'].body.strip.to_i

      if power && Ev3::MovementController::POWER_RANGE.include?(power)
        movement_state.power = power

        [204, {}, []]
      else
        [400, {}, ['invalid power value']]
      end
    end
  end

  post '/direction' do
    run ->(env) do
      direction = env['request'].body.strip.to_i

      if direction && Ev3::MovementController::DIRECTION_RANGE.include?(direction)
        movement_state.direction = direction

        [204, {}, []]
      else
        [400, {}, ['invalid direction value']]
      end
    end
  end
end

# Setup and run the server
SimpleHttpServer.new(
  server_ip: 'ev3dev.local',
  port: 8000,
  debug: true,
  app: APPLICATION
).run
