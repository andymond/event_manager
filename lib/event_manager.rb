require "csv"
require "google/apis/civicinfo_v2"
require "erb"

class EventManager

  attr_reader :contents,
              :civic_info,
              :template_letter,
              :erb_template

  def initialize(csv_file = "./data/event_attendees.csv")
    @contents = CSV.open csv_file, headers: true, header_converters: :symbol
    @civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    @civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    @template_letter = File.read "./lib/form_letter.erb"
    @erb_template = ERB.new(template_letter)
  end

  def start_message
    "Event Manager initialized"
  end

  def parse_csv_file
    contents.each do |row|
      id = row[0]
      name = row[:first_name]
      zipcode = clean_zipcode(row[:zipcode])
      legislators = legislators_by_zipcode(zipcode)

      form_letter = erb_template.result(binding)

      save_thank_you_letters(id, form_letter)
    end
  end

  def save_thank_you_letters(id, form_letter)
    Dir.mkdir("./lib/output") unless Dir.exists?("./lib/output")

    filename = "output/thanks_#{id}"

    File.open(filename, "w") do |file|
      puts form_letter
    end
  end

  def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, "0")[0..4]
  end

  def legislators_by_zipcode(zipcode)
    begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ['legislatorUpperBody', 'legislatorLowerBody'])

      legislators = legislators.officials
    rescue
      "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
  end

end

manager = EventManager.new
puts manager.start_message
manager.parse_csv_file
