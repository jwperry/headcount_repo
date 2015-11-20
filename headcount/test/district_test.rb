require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class DistrictTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @dr.load_data({ :enrollment =>          { :kindergarten => "./data/Kindergartners in full-day program.csv" },
                    :statewide_testing =>   { :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv" },
                    :economic_profile =>    { :median_household_income => "./data/Median household income.csv" }})
  end

  def test_district_class_exists
    assert District.new({:name => "Colorado"})
  end

  def test_name_method_return_the_upcased_string_name_of_district
    d = District.new({:name => "Colorado"})

    assert_equal "COLORADO", d.name
  end

  def test_set_enrollment_method_returns_an_enrollment_object
    assert_equal Enrollment, @dr.find_by_name("Colorado").enrollment.class
  end

  def test_set_statewide_test_method_returns_a_statewide_test_object
    assert_equal StatewideTest, @dr.find_by_name("Academy 20").statewide_test.class
  end

  def test_set_economic_profile_method_returns_an_economic_profile_object
    assert_equal EconomicProfile, @dr.find_by_name("Colorado").economic_profile.class
  end

end
