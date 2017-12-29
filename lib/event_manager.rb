require "csv"
require "google/apis/civicinfo_v2"

class EventManager

  attr_reader :contents, :civic_info, :template_letter

  def initialize(csv_file = "./data/event_attendees.csv")
    @contents = CSV.open csv_file, headers: true, header_converters: :symbol
    @civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    @civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    @template_letter = File.read "./lib/form_letter.html"
  end

  def start_message
    "Event Manager initialized"
  end

  def parse_csv_file
    contents.each do |row|
      name = row[:first_name]
      zipcode = clean_zipcode(row[:zipcode])
      legislator_names = legislator_names_by_zipcode(zipcode)

      personal_letter = template_letter.gsub("FIRST_NAME", name)
      personal_letter.gsub!("LEGISLATORS", legislator_names)

      puts personal_letter
    end
  end

  def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, "0")[0..4]
  end

  def legislator_names_by_zipcode(zipcode)
    begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ['legislatorUpperBody', 'legislatorLowerBody'])

      legislators = legislators.officials
      legislators.map(&:name).join(", ")
    rescue
      "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
  end

end

manager = EventManager.new
puts manager.start_message
manager.parse_csv_file
