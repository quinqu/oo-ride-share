require 'csv'
require 'time'
require_relative 'csv_record'

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id, :start_time, :end_time, :cost, :rating, :driver, :driver_id

    def initialize(
          id:,
          passenger: nil,
          passenger_id: nil,
          start_time:,
          end_time:,
          cost: nil,
          rating:, 
          driver: nil, 
          driver_id: nil
        )
      super(id)

      if passenger
        @passenger = passenger
        @passenger_id = passenger.id

      elsif passenger_id
        @passenger_id = passenger_id

      else
        raise ArgumentError, 'Passenger or Passenger ID is required'
      end
      
      unless end_time == nil 
        if end_time > start_time
          @start_time = start_time
          @end_time = end_time
        else 
          raise ArgumentError.new("You can't end a trip before one starts")
        end 
      end 
       
      @cost = cost
      

      unless rating == nil
        if rating < 1 || rating > 5
          raise ArgumentError, "Invalid rating"
        else
          @rating = rating
        end
      end

      if driver
        @driver = driver
        @driver_id = driver.id
      elsif driver_id
        @driver_id = driver_id
      else
        raise ArgumentError, 'Driver or Driver ID is required'
      end
    end

    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
        "ID=#{id.inspect} " +
        "PassengerID=#{passenger&.id.inspect}>"
    end

    def connect(passenger, driver)
      @passenger = passenger
      passenger.add_trip(self)
      @driver = driver 
      driver.add_trip(self)
    end
    
    def calculate_seconds
      unless @end_time == nil 
        return @end_time - @start_time
      end 
    end 

    private

    def self.from_csv(record)
      return self.new(
               id: record[:id],
               passenger_id: record[:passenger_id],
               start_time: Time.parse(record[:start_time]),
               end_time: Time.parse(record[:end_time]),
               cost: record[:cost],
               rating: record[:rating],
               driver_id: record[:driver_id]
             )
    end
  end
end
