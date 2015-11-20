require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'
require './lib/headcount_analyst'

class HeadcountAnalystTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @ha = HeadcountAnalyst.new(@dr)
    @dr.load_data({:enrollment => {
                      :kindergarten => "./data/Kindergartners in full-day program.csv",
                      :high_school_graduation => "./data/High school graduation rates.csv"
                    },
                   :statewide_testing => {
                      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
                      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
                      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
                    }
                    })
  end

  def test_headcount_class_exists
    assert HeadcountAnalyst.new(@dr)
  end

  def test_kindergarten_participation_rate_variation_compares_two_districts_and_returns_a_3_digit_float
    assert_equal 0.766, @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
  end

  def test_kindergarten_participation_rate_variation_trend_returns_a_hash_with_years_and_three_digit_floats
    assert_equal({2007=>0.992, 2006=>1.05,
                  2005=>0.96,  2004=>1.257,
                  2008=>0.717, 2009=>0.652,
                  2010=>0.681, 2011=>0.727,
                  2012=>0.688, 2013=>0.694, 2014=>0.661}, @ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO'))
  end

  def test_get_kp_data_grabs_the_proper_raw_data
    assert_equal [0.21756, 0.11923, 0.35254,
                  0.30224, 0.7658, 0.98,
                  0.99327, 0.993, 1.0, 1.0, 1.0], @ha.get_kp_data(@dr.find_by_name("CANON CITY RE-1"))
  end

  def test_get_kp_data_with_year_grabs_the_proper_raw_data
    assert_equal({2007=>0.21756, 2006=>0.11923, 2005=>0.35254,
                  2004=>0.30224, 2008=>0.7658, 2009=>0.98,
                  2010=>0.99327, 2011=>0.993, 2012=>1.0, 2013=>1.0, 2014=>1.0}, @ha.get_kp_data_with_year(@dr.find_by_name("CANON CITY RE-1")))
  end

  def test_high_school_graduation_rate_variation_compares_two_districts_and_returns_a_3_digit_float
    assert_equal 1.16, @ha.high_school_graduation_rate_variation('HUERFANO RE-1', :against => 'IGNACIO 11 JT')
  end

  def test_kindergarten_participation_against_high_school_graduation_returns_truncated_float
    assert_equal 0.641, @ha.kindergarten_participation_against_high_school_graduation("ACADEMY 20")
  end

  def test_get_hs_grad_data_grabs_the_proper_raw_data
    assert_equal [0.774, 0.787, 0.79121, 0.80226, 0.755], @ha.get_hs_grad_data(@dr.find_by_name("JOHNSTOWN-MILLIKEN RE-5J"))
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_recognizes_statewide
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_recognizes_non_statewide_for
    assert @ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'ACADEMY 20')
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_recognizes_across_series_of_districts
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(:across => ['MONTEZUMA-CORTEZ RE-1', 'OURAY R-1', 'MOFFAT 2', 'WIGGINS RE-50(J)', 'SILVERTON 1'])
  end

  def test_districts_with_correlation_returns_correct_boolean
    assert 0.7 >  @ha.districts_with_correlation([
                  @dr.enrollment_repo.find_by_name('MONTEZUMA-CORTEZ RE-1'),
                  @dr.enrollment_repo.find_by_name('OURAY R-1'),
                  @dr.enrollment_repo.find_by_name('MOFFAT 2'),
                  @dr.enrollment_repo.find_by_name('WIGGINS RE-50(J)'),
                  @dr.enrollment_repo.find_by_name('SILVERTON 1')])
  end

  def test_top_statewide_test_year_over_year_raises_an_error_when_an_incorrect_grade_is_passed_in
    assert_raises "UnknownDataError: 9 is not a known grade" do
      @ha.top_statewide_test_year_over_year_growth(grade: 9, subject: :math)
    end
  end

  def test_top_statewide_test_year_over_year_raises_an_error_when_a_grade_is_not_passed_in
    assert_raises "InsufficientInformationError: A grade must be provided to answer this question" do
      @ha.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_get_gradekey
    assert_equal :third_grade, @ha.get_gradekey(3)

    assert_equal :eighth_grade, @ha.get_gradekey(8)
  end

  def test_get_averages_with_single_leader
    assert_equal 0.114, @ha.get_averages_with_single_leader({grade: 3, subject: :reading}, :third_grade)[1]
  end

  def test_get_averages_with_multiple_leaders
    assert_equal ["CENTENNIAL R-1", 0.114], @ha.get_averages_with_multiple_leaders({grade: 3, subject: :reading}, :third_grade)
  end

  def test_averages_across_all_subjects
    assert_equal ["DE BEQUE 49JT", 0.17], @ha.get_averages_with_multiple_leaders({grade: 8, subject: :writing}, :eighth_grade)
  end

  def test_get_avg_method_does_the_maths_right
    data = [2.01, 5.0, 7.64, 11.92]

    assert_equal 6.6425, @ha.get_avg(data)
  end

  def test_truncate_method_also_does_the_math_thing_correctly
    number = 0.38759

    assert_equal 0.387, @ha.truncate(number)
  end

end
