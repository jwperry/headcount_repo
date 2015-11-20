require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'
require './lib/formatter'

class FormatterTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @formatter = Formatter.new(@dr)
    @dr.load_data({ :enrollment =>
                    { :kindergarten =>           "./data/Kindergartners in full-day program.csv",
                      :high_school_graduation => "./data/High school graduation rates.csv"
                    }
                  })
  end

  def test_call_formatter_formats_data_correctly
    data = {"BYERS 32J"=> [{:location=>"BYERS 32J", :timeframe=>2007, :dataformat=>"Percent", :data=>1},
                           {:location=>"BYERS 32J", :timeframe=>2006, :dataformat=>"Percent", :data=>1},
                           {:location=>"BYERS 32J", :timeframe=>2005, :dataformat=>"Percent",:data=>1}]}

    expected = [{:name=>"BYERS 32J", :kindergarten_participation=>{2007=>1, 2006=>1, 2005=>1}}]

    assert_equal expected, @formatter.call_formatter(:kindergarten, data)
  end

  def test_package_stores_all_unique_districts
    assert_equal 179, @dr.enrollment_repo.enrollments.length
  end

  def test_that_extract_years_method_extracts_raw_data
    extracted_years = @formatter.extract_years_from_district_rows([{:location   => "Colorado",
                                                                    :timeframe  => 2007,
                                                                    :dataformat => "Percent",
                                                                    :data       => 0.39465}])

    assert_equal({2007=>0.39465}, extracted_years)
  end

  def test_kindergarten_formatter
    parsed_data = {"ADAMS-ARAPAHOE 28J"=>[{:location=>"ADAMS-ARAPAHOE 28J", :timeframe=>2007, :dataformat=>"Percent", :data=>0.47359},
                                          {:location=>"ADAMS-ARAPAHOE 28J", :timeframe=>2006, :dataformat=>"Percent", :data=>0.37013},
                                          {:location=>"ADAMS-ARAPAHOE 28J", :timeframe=>2005, :dataformat=>"Percent", :data=>0.20176}]}

    expected = [{:name=>"ADAMS-ARAPAHOE 28J", :kindergarten_participation=>{2007=>0.47359, 2006=>0.37013, 2005=>0.20176}}]

    assert_equal expected, @formatter.kindergarten_formatter(parsed_data)
  end

  def test_high_school_graduation_formatter
    parsed_data = {"ACADEMY 20"=>[{:location=>"ACADEMY 20", :timeframe=>2011, :dataformat=>"Percent", :data=>0.895},
                                  {:location=>"ACADEMY 20", :timeframe=>2012, :dataformat=>"Percent", :data=>0.88983},
                                  {:location=>"ACADEMY 20", :timeframe=>2013, :dataformat=>"Percent", :data=>0.91373}]}

    expected = [{:name=>"ACADEMY 20", :high_school_graduation=>{2011=>0.895, 2012=>0.88983, 2013=>0.91373}}]

    assert_equal expected, @formatter.high_school_graduation_formatter(parsed_data)
  end

  def test_third_grade_formatter_formats_correctly
    data = {"Colorado"=> [{:location=>"Colorado", :score=>:math, :timeframe=>2008, :dataformat=>"Percent", :data=>0.697},
                          {:location=>"Colorado", :score=>:reading, :timeframe=>2008, :dataformat=>"Percent", :data=>0.703}]}

    expected = [{:name=>"Colorado", :third_grade=>[{:location=>"Colorado",
                                                    :score=>:math,
                                                    :timeframe=>2008,
                                                    :dataformat=>"Percent",
                                                    :data=>0.697},
                                                   {:location=>"Colorado",
                                                    :score=>:reading,
                                                    :timeframe=>2008,
                                                    :dataformat=>"Percent",
                                                    :data=>0.703}]}]

    assert_equal expected, @formatter.third_grade_formatter(data)
  end

  def test_eighth_grade_formatter_formats_correctly
    data = {"Colorado"=> [{:location=>"Colorado", :score=>:math, :timeframe=>2008, :dataformat=>"Percent", :data=>0.697},
                          {:location=>"Colorado", :score=>:reading, :timeframe=>2008, :dataformat=>"Percent", :data=>0.703}]}

    expected = [{:name=>"Colorado", :eighth_grade=>[{:location=>"Colorado",
                                                     :score=>:math,
                                                     :timeframe=>2008,
                                                     :dataformat=>"Percent",
                                                     :data=>0.697},
                                                    {:location=>"Colorado",
                                                     :score=>:reading,
                                                     :timeframe=>2008,
                                                     :dataformat=>"Percent",
                                                     :data=>0.703}]}]

    assert_equal expected, @formatter.eighth_grade_formatter(data)
  end

  def test_math_formatter_formats_correctly
    data = {"Colorado"=> [{:location=>"Colorado", :score=>:math, :timeframe=>2008, :dataformat=>"Percent", :data=>0.697},
                          {:location=>"Colorado", :score=>:math, :timeframe=>2009, :dataformat=>"Percent", :data=>0.703}]}

    expected = [{:name=>"Colorado", :math=>[{:location=>"Colorado",
                                             :score=>:math,
                                             :timeframe=>2008,
                                             :dataformat=>"Percent",
                                             :data=>0.697},
                                            {:location=>"Colorado",
                                             :score=>:math,
                                             :timeframe=>2009,
                                             :dataformat=>"Percent",
                                             :data=>0.703}]}]

    assert_equal expected, @formatter.math_formatter(data)
  end

  def test_reading_formatter_formats_correctly
    data = {"Colorado"=> [{:location=>"Colorado", :score=>:reading, :timeframe=>2008, :dataformat=>"Percent", :data=>0.697},
                          {:location=>"Colorado", :score=>:reading, :timeframe=>2009, :dataformat=>"Percent", :data=>0.703}]}

    expected = [{:name=>"Colorado", :reading=>[{:location=>"Colorado",
                                                :score=>:reading,
                                                :timeframe=>2008,
                                                :dataformat=>"Percent",
                                                :data=>0.697},
                                               {:location=>"Colorado",
                                                :score=>:reading,
                                                :timeframe=>2009,
                                                :dataformat=>"Percent",
                                                :data=>0.703}]}]

    assert_equal expected, @formatter.reading_formatter(data)
  end

  def test_writing_formatter_formats_correctly
    data = {"Colorado"=> [{:location=>"Colorado", :score=>:writing, :timeframe=>2008, :dataformat=>"Percent", :data=>0.697},
                          {:location=>"Colorado", :score=>:writing, :timeframe=>2009, :dataformat=>"Percent", :data=>0.703}]}

    expected = [{:name=>"Colorado", :writing=>[{:location=>"Colorado",
                                                :score=>:writing,
                                                :timeframe=>2008,
                                                :dataformat=>"Percent",
                                                :data=>0.697},
                                               {:location=>"Colorado",
                                                :score=>:writing,
                                                :timeframe=>2009,
                                                :dataformat=>"Percent",
                                                :data=>0.703}]}]

    assert_equal expected, @formatter.writing_formatter(data)
  end

  def test_median_household_income_formatter_formats_correctly
    data = {"ADAMS COUNTY 14"=> [{:location=>"ADAM COUNTY 14", :timeframe=>"2005-2009", :dataformat=>"Currency", :data=>41382},
                                 {:location=>"ADAM COUNTY 14", :timeframe=>"2006-2010", :dataformat=>"Currency", :data=>40740}]}

    expected = [{:name=>"ADAMS COUNTY 14", :median_household_income=>[{:location=>"ADAM COUNTY 14",
                                                                       :timeframe=>"2005-2009",
                                                                       :dataformat=>"Currency",
                                                                       :data=>41382},
                                                                      {:location=>"ADAM COUNTY 14",
                                                                       :timeframe=>"2006-2010",
                                                                       :dataformat=>"Currency",
                                                                       :data=>40740}]}]

    assert_equal expected, @formatter.median_household_income_formatter(data)
  end

  def test_children_in_poverty_formatter_formats_correctly
    data = {"AGUILAR REORGANIZED"=> [{:location=>"AGUILAR REORGANIZED", :timeframe=>"1995", :dataformat=>"Percent", :data=>0.45},
                                     {:location=>"AGUILAR REORGANIZED", :timeframe=>"1997", :dataformat=>"Percent", :data=>0.52}]}

    expected = [{:name=>"AGUILAR REORGANIZED", :median_household_income=>[{:location=>"AGUILAR REORGANIZED",
                                                                           :timeframe=>"1995",
                                                                           :dataformat=>"Percent",
                                                                           :data=>0.45},
                                                                          {:location=>"AGUILAR REORGANIZED",
                                                                           :timeframe=>"1997",
                                                                           :dataformat=>"Percent",
                                                                           :data=>0.52}]}]

    assert_equal expected, @formatter.median_household_income_formatter(data)
  end

  def test_free_or_reduced_price_lunch_formatter_formats_correctly
    data = {"Colorado"=> [{:location=>"Colorado", :poverty_level=>"Eligible for Reduced Price Lunch", :timeframe=>"2000", :dataformat=>"Percent", :data=>0.07},
                          {:location=>"Colorado", :poverty_level=>"Eligible for Reduced Price Lunch", :timeframe=>"2001", :dataformat=>"Percent", :data=>0.20522}]}

    expected = [{:name=>"Colorado", :free_or_reduced_price_lunch=>[{:location=>"Colorado",
                                                                    :poverty_level=>"Eligible for Reduced Price Lunch",
                                                                    :timeframe=>"2000",
                                                                    :dataformat=>"Percent",
                                                                    :data=>0.07},
                                                                   {:location=>"Colorado",
                                                                     :poverty_level=>"Eligible for Reduced Price Lunch",
                                                                     :timeframe=>"2001", :dataformat=>"Percent",
                                                                     :data=>0.20522}]}]

    assert_equal expected, @formatter.free_or_reduced_price_lunch_formatter(data)
  end

  def test_title_i_formatter_formats_correctly
    data = {"AKRON R-1"=> [{:location=>"AKRON R-1", :timeframe=>"2011", :dataformat=>"Percent", :data=>0.17},
                           {:location=>"AKRON R-1", :timeframe=>"2012", :dataformat=>"Percent", :data=>0.14972}]}

    expected = [{:name=>"AKRON R-1", :title_i=>[{:location=>"AKRON R-1",
                                                 :timeframe=>"2011",
                                                 :dataformat=>"Percent",
                                                 :data=>0.17},
                                                {:location=>"AKRON R-1",
                                                 :timeframe=>"2012",
                                                 :dataformat=>"Percent",
                                                 :data=>0.14972}]}]

    assert_equal expected, @formatter.title_i_formatter(data)
  end

end
