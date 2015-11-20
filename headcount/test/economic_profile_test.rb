require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class EconomicProfileTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @epr = @dr.economic_profile_repo
    @epr.load_data({:economic_profile => { :median_household_income => "./data/Median household income.csv",
                                           :children_in_poverty => "./data/School-aged children in poverty.csv",
                                           :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
                                           :title_i => "./data/Title I students.csv"}})
    @economic_profile = @epr.find_by_name("ACADEMY 20")
  end

  def test_econonic_profile_class_exists
    data = {:median_household_income => {[2014, 2015] => 50000, [2013, 2014] => 60000},
            :children_in_poverty => {2012 => 0.1845},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543}}
    assert EconomicProfile.new(data)
  end

  def test_truncate_number_method_still_works
    assert_equal 0.472, @economic_profile.truncate(0.4721894)
  end

  def test_name_method_returns_name
    assert_equal "ACADEMY 20", @economic_profile.name
  end

  def test_estimated_median_household_income_in_year_returns_an_integer
    assert_equal 87635.0, @economic_profile.estimated_median_household_income_in_year(2009)
  end

  def test_estimated_median_household_income_in_year_raises_an_error_when_an_unknown_year_is_passed_in
    assert_raises "UnknownDataError" do
      @economic_profile.estimated_median_household_income_in_year(1907)
    end
  end

  def test_median_household_income_average_returns_an_integer_representing_the_average_of_known_incomes
    assert_equal 87635.4, @economic_profile.median_household_income_average
  end

  def test_children_in_poverty_in_year_returns_a_three_digit_float
    assert_equal 0.064, @economic_profile.children_in_poverty_in_year(2012)
  end

  def test_children_in_poverty_in_year_raises_an_error_with_an_unknown_year
    assert_raises "UnknownDataError" do
      @economic_profile.children_in_poverty_in_year(1909)
    end
  end

  def test_free_or_reduced_price_lunch_percentage_in_year_returns_a_three_digit_float_percentage
    assert_equal 0.127, @economic_profile.free_or_reduced_price_lunch_percentage_in_year(2014)
  end

  def test_free_or_reduced_price_lunch_percentage_in_year_raises_an_error_with_an_unknown_year
    assert_raises "UnknownDataError" do
      @economic_profile.free_or_reduced_price_lunch_percentage_in_year(1289)
    end
  end

  def test_free_or_reduced_price_lunch_number_in_year_returns_an_integer_representing_children_receiving_free_or_reduced_price_lunch
    assert_equal 3006.0, @economic_profile.free_or_reduced_price_lunch_number_in_year(2012)
  end

  def test_free_or_reduced_price_lunch_number_in_year_raises_an_error_with_an_unknown_year
    assert_raises "UnknownDataError" do
      @economic_profile.free_or_reduced_price_lunch_number_in_year(2222)
    end
  end

  def test_title_i_in_year_returns_a_three_digit_float_percentage
    assert_equal 0.027, @economic_profile.title_i_in_year(2014)
  end

  def test_title_i_in_year_raises_an_error_with_an_unknown_year
    assert_raises "UnknownDataError" do
      @economic_profile.title_i_in_year(1980)
    end
  end

  def test_year_is_valid_with_range_returns_the_correct_boolean
    assert @economic_profile.year_is_valid_with_range(2012)

    refute @economic_profile.year_is_valid_with_range(1900)
  end

  def test_year_is_valid_with_percent_returns_the_correct_boolean
    assert @economic_profile.year_is_valid_with_percent(2012)

    refute @economic_profile.year_is_valid_with_percent(9999)
  end

  def test_year_is_valid_for_free_or_reduced_lunch_percent_returns_the_correct_boolean
    assert @economic_profile.year_is_valid_for_free_or_reduced_lunch_percent(2013)

    refute @economic_profile.year_is_valid_for_free_or_reduced_lunch_percent(2209)
  end

  def test_year_is_valid_for_free_or_reduced_lunch_num_returns_the_correct_boolean
    assert @economic_profile.year_is_valid_for_free_or_reduced_lunch_num(2013)

    refute @economic_profile.year_is_valid_for_free_or_reduced_lunch_num(2209)
  end

  def test_year_is_valid_for_title_i_returns_the_correct_boolean
    assert @economic_profile.year_is_valid_for_title_i(2012)
    
    refute @economic_profile.year_is_valid_for_title_i(2444)
  end

  def test_get_year_range_converts_a_string_range_to_a_usable_integer_range
    assert_equal (2008..2014), @economic_profile.get_year_range("2008-2014")
  end

end
