require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end
require './lib/event_manager'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'

class EventManagerTest < Minitest::Test

  def test_file_check_returns_boolean_for_files
    assert File.exist?("./data/event_attendees.csv")
    refute File.exist?("oh boy")
  end

  def test_start_message
    manager = EventManager.new

    assert_equal "Event Manager initialized", manager.start_message
  end

  def test_parse_csv_file_puts_names
    manager = EventManager.new

    assert_nil manager.parse_csv_file
  end

  def test_clean_zipcode_adds_0s_to_less_than_five_digit_strings
    manager = EventManager.new

    assert_equal "00123", manager.clean_zipcode("123")
  end

end
