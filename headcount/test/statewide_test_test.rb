require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class StatewideTestTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @str = @dr.statewide_test_repo
    @str.load_data({:statewide_testing => {:third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                                           :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                                           :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
                                           :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
                                           :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
                                          }
                      })
    @statewide_test = @str.find_by_name("ACADEMY 20")
  end

  def test_statewide_test_class_exists
    assert StatewideTest.new("stuff")
  end

  def test_truncate_number_method_works
    assert_equal 0.472, @statewide_test.truncate(0.4721894)
  end

  def test_name_method_returns_name
    assert_equal "ACADEMY 20", @statewide_test.name
  end

  def test_proficient_by_grade_method_takes_a_year_as_an_integer_and_returns_a_data_hash
    expected = {2008=>{:math=>0.857, :reading=>0.866, :writing=>0.671},
                2009=>{:math=>0.824, :reading=>0.862, :writing=>0.706},
                2010=>{:math=>0.849, :reading=>0.864, :writing=>0.662},
                2011=>{:math=>0.819, :reading=>0.867, :writing=>0.678},
                2012=>{:reading=>0.87, :math=>0.83, :writing=>0.655},
                2013=>{:math=>0.855, :reading=>0.859, :writing=>0.668},
                2014=>{:math=>0.834, :reading=>0.831, :writing=>0.639}}

    assert_equal expected, @statewide_test.proficient_by_grade(3)
  end

  def test_proficient_by_grade_raises_an_unknown_data_error_with_an_unknown_grade
    assert_raises "UnknownDataError" do
      @statewide_test.proficient_by_grade(6)
    end
  end

  def test_proficient_by_grade_raises_an_unknown_data_error_with_irrelevent_data
    assert_raises "UnknownDataError" do
      @statewide_test.proficient_by_grade("nachos!!")
    end
  end

  def test_proficient_by_race_or_ethnicity_method_takes_a_race_as_a_symbol_and_returns_a_data_hash
    expected = {2011=>{:math=>0.816, :reading=>0.897, :writing=>0.826},
                2012=>{:math=>0.818, :reading=>0.893, :writing=>0.808},
                2013=>{:math=>0.805, :reading=>0.901, :writing=>0.81},
                2014=>{:math=>0.8, :reading=>0.855, :writing=>0.789}}

    assert_equal expected, @statewide_test.proficient_by_race_or_ethnicity(:asian)
  end

  def test_proficient_by_race_raises_an_unknown_race_error_with_an_unknown_race
    assert_raises "UnknownRaceError" do
      @statewide_test.proficient_by_race_or_ethnicity(:alien)
    end
  end

  def test_proficient_by_race_raises_an_unknown_race_error_with_when_race_is_not_passed_in_as_a_symbol
    assert_raises "UnknownRaceError" do
      @statewide_test.proficient_by_race_or_ethnicity("black")
    end
  end

  def test_proficient_by_race_raises_an_unknown_race_error_with_irrelevent_data
    assert_raises "UnknownRaceError" do
      @statewide_test.proficient_by_race_or_ethnicity(1979)
    end
  end

  def test_proficient_for_subject_by_grade_in_year_takes_correct_3_params_and_returns_a_three_digit_float
    assert_equal 0.857, @statewide_test.proficient_for_subject_by_grade_in_year(:math, 3, 2008)
  end

  def test_proficient_for_subject_by_grade_in_year_raises_an_error_with_any_invalid_parameter
    assert_raises "UnknownDataError" do
      @statewide_test.proficient_for_subject_by_grade_in_year(:science, 3, 2008)
    end

    assert_raises "UnknownDataError" do
      @statewide_test.proficient_for_subject_by_grade_in_year(:math, 11, 2008)
    end

    assert_raises "UnknownDataError" do
      @statewide_test.proficient_for_subject_by_grade_in_year(:math, 11, 1999)
    end
  end

  def test_proficient_for_subject_by_race_in_year_takes_correct_3_params_and_returns_a_three_digit_float
    assert_equal 0.818, @statewide_test.proficient_for_subject_by_race_in_year(:math, :asian, 2012)
  end

  def test_proficient_for_subject_by_race_in_year_raises_an_error_with_any_invalid_parameter
    assert_raises "UnknownDataError" do
      @statewide_test.proficient_for_subject_by_race_in_year(:history, :asian, 2012)
    end

    assert_raises "UnknownDataError" do
      @statewide_test.proficient_for_subject_by_race_in_year(:history, :white_guy, 2012)
    end

    assert_raises "UnknownDataError" do
      @statewide_test.proficient_for_subject_by_race_in_year(:history, :asian, 2021)
    end
  end

  def test_grade_is_valid_method_functions_properly
    assert_raises "UnknownDataError" do
      @statewide_test.grade_is_valid(1)
    end
  end

  def test_race_or_ethnicity_is_valid_method_functions_properly
    assert_raises "UnknownRaceError" do
      @statewide_test.race_or_ethnicity_is_valid(:carebear)
    end
  end

  def test_score_is_valid_method_functions_properly
    assert_raises "UnknownRaceError" do
      @statewide_test.score_is_valid(:woodshop)
    end
  end

  def test_get_data_for_subject_by_grade_in_year_returns_raw_data
    assert_equal "0.672", @statewide_test.get_data_for_subject_by_grade_in_year(:math, :eighth_grade, 2010)
  end

  def test_get_data_for_subject_by_race_in_year_returns_raw_data
    assert_equal "0.69469", @statewide_test.get_data_for_subject_by_race_in_year(:reading, :black, 2012)
  end

  def test_query_hash_by_three_method_grabs_the_data_we_need
    expected = { 2008=>{:math=>0.857, :reading=>0.866, :writing=>0.671},
                 2009=>{:math=>0.824, :reading=>0.862, :writing=>0.706},
                 2010=>{:math=>0.849, :reading=>0.864, :writing=>0.662},
                 2011=>{:math=>0.819, :reading=>0.867, :writing=>0.678},
                 2012=>{:reading=>0.87, :math=>0.83, :writing=>0.655},
                 2013=>{:math=>0.855, :reading=>0.859, :writing=>0.668},
                 2014=>{:math=>0.834, :reading=>0.831, :writing=>0.639} }

    assert_equal expected, @statewide_test.query_hash_by_three(@statewide_test.data[:third_grade], :timeframe, [{ :score => :data }])
  end

  def test_query_hash_by_three_with_race_by_subject_method_grabs_the_data_we_need
    expected = { 2011=>{:math=>0.816},
                 2012=>{:math=>0.818},
                 2013=>{:math=>0.805},
                 2014=>{:math=>0.8}}

    assert_equal expected, @statewide_test.query_hash_by_three_with_race_by_subject(:asian, :math, @statewide_test.data[:math], :timeframe, [{ :score => :data }])
  end

  def test_year_over_year_avg_with_equal_weighting_returns_correct_raw_data
    expected = -0.002666666666666669

    assert_equal expected, @statewide_test.year_over_year_avg(:eighth_grade, :reading)
  end

  def test_year_over_year_avg_with_custom_weighting_returns_correct_raw_data
    expected = 0.0024133333333333324

    assert_equal expected, @statewide_test.year_over_year_avg(:eighth_grade, :all, {:math => 0.5, :reading => 0.5, :writing => 0.0})
  end

  def test_earliest_year_data_for_one_subject_returns_correct_raw_data
    assert_equal [2008.0, 0.866], @statewide_test.earliest_year_data(:third_grade, :reading)
  end

  def test_latest_year_data_for_one_subject_returns_correct_raw_data
    assert_equal [2014.0, 0.68496], @statewide_test.latest_year_data(:eighth_grade, :math)
  end

  def test_get_avg_method_does_the_maths_like_a_math_whiz
    assert_equal 0.013750000000000004, @statewide_test.get_avg([2008.0, 0.866], [2014.0, 0.9485])
  end

  def test_get_weighted_avgs_returns_correct_raw_data
    assert_equal 0.002393666666666668, @statewide_test.get_weighted_avgs(:eighth_grade, {:math => 0.4, :reading => 0.4, :writing => 0.2})

    assert_equal (-0.0040526666666666645), @statewide_test.get_weighted_avgs(:third_grade, {:math => 0.8, :reading => 0.0, :writing => 0.2})
  end

  def test_math_data
    assert_equal (-0.0037499999999999942), @statewide_test.math_data(:third_grade)
  end

  def test_reading_data
    assert_equal (-0.005831666666666661), @statewide_test.reading_data(:third_grade)
  end

  def test_writing_data
    assert_equal 0.0023150000000000115, @statewide_test.writing_data(:eighth_grade)
  end

end
