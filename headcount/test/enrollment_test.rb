require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class EnrollmentTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @er = @dr.enrollment_repo
    @er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                    :high_school_graduation => "./data/High school graduation rates.csv"
                                  }
                  })
    @enrollment = @er.find_by_name("ACADEMY 20")
  end

  def test_enrollment_class_exists
    assert Enrollment.new("stuff")
  end

  def test_truncate_number_method_works
    assert_equal 0.472, @enrollment.truncate(0.4721894)
  end

  def test_name_method_returns_name
    assert_equal "ACADEMY 20", @enrollment.name
  end

  def test_kindergarten_participation_by_year_returns_a_data_hash_with_3_digit_floats
    expected = {2007=>0.391, 2006=>0.353, 2005=>0.267, 2004=>0.302,
                2008=>0.384, 2009=>0.39, 2010=>0.436, 2011=>0.489,
                2012=>0.478, 2013=>0.487, 2014=>0.49}

    assert_equal expected, @enrollment.kindergarten_participation_by_year
  end

  def test_kindergarten_participation_in_year_returns_a_3_digit_float
    assert_equal 0.489, @enrollment.kindergarten_participation_in_year(2011)
  end

  def test_kindergarten_participation_in_year_returns_nil_with_an_unknown_year
    assert_equal nil, @enrollment.kindergarten_participation_in_year(2000)
  end

  def test_kindergarten_participation_in_year_returns_nil_with_an_invalid_format_year
    assert_equal nil, @enrollment.kindergarten_participation_in_year("2002")
  end

  def test_high_school_graduation_by_year_returns_a_data_hash_with_3_digit_floats
    expected = {2010=>0.895, 2011=>0.895, 2012=>0.889, 2013=>0.913, 2014=>0.898}

    assert_equal expected, @enrollment.graduation_rate_by_year
  end

  def test_high_school_graduation_in_year_returns_a_3_digit_float
    assert_equal 0.895, @enrollment.graduation_rate_in_year(2011)
  end

  def test_high_school_graduation_in_year_returns_nil_with_an_unknown_year
    assert_equal nil, @enrollment.graduation_rate_in_year(2001)
  end

  def test_high_school_graduation_in_year_returns_nil_with_an_invalid_format_year
    assert_equal nil, @enrollment.graduation_rate_in_year("2007")
  end
end
