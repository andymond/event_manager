require "CSV"

class EventManager

  attr_reader :contents

  def initialize(csv_file = "./data/event_attendees.csv")
    @contents = CSV.open csv_file, headers: true, header_converters: :symbol
  end

  def start_message
    "Event Manager initialized"
  end

  def parse_csv_file
    contents.each do |row|
      name = row[:first_name]
      zipcode = row[:zipcode]

      clean_zipcode(zipcode)

      puts "#{name} #{zipcode}"
    end
  end

  def clean_zipcode(zipcode)
    if zipcode.nil?
      zipcode = "00000"
    elsif zipcode.length < 5
      zipcode = zipcode.rjust(5, "0")
    elsif zipcode.length > 5
      zipcode = zipcode.slice(0..4)
    end
  end
end

manager = EventManager.new
puts manager.start_message
manager.parse_csv_file
