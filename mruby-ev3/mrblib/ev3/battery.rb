module Ev3
  # Information about the EV3 battery
  class Battery < Device
    SYSFS_CLASS = 'power_supply/lego-ev3-battery'

    class << self
      def detect
        new(File.join(Ev3.sysfs_class_path, SYSFS_CLASS))
      end
    end

    # @return [Integer] the current battery current in microamperes
    def current
      read_attribute('current_now').to_i
    end

    # @return [:unknown, :'li-ion', :nimh] returns :'li-ion' when the rechargeable battery pack is installed,
    #   and :unknown otherwise. You can send `:nimh` to `#technology=` if you use NiMH batteries.
    def technology
      read_attribute('technology').downcase.to_sym
    end

    # @return [Integer] the nominal maximum voltage for the battery technology. This value may never be reached. Value
    #   is in microvolts.
    def maximum_voltage
      read_attribute('voltage_max_design').to_i.div(10) # for some reason, the value on the EV3 is not microvolts
    end

    # @return [Integer] the nominal minimum voltage for the battery technology. The value is in microvolts.
    def minimum_voltage
      read_attribute('voltage_min_design').to_i.div(10) # for some reason, the value on the EV3 is not microvolts
    end

    # @return [Integer] the current battery voltage in microvolts.
    def voltage
      read_attribute('voltage_now').to_i
    end

    # @return [true, false] true when the battery voltage is below 15% of the capacity (in this case meaning the
    #   voltage range between max and min voltage of the battery)
    #
    # @raise [RuntimeError] when the battery does not support minimum or maximum voltage information
    def low?
      max = maximum_voltage
      min = minimum_voltage
      raise(RuntimeError, 'battery type does not support #low?') if max.zero? || min.zero?

      range = max - min

      lower_treshold = Rational(min, 1) + Rational(range * 15, 100)

      (Rational(voltage, 1) <=> lower_treshold) == -1
    end
  end
end
