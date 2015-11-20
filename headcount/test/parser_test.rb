require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'
require './lib/parser'

class ParserTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @parser = Parser.new
  end

  def test_that_parser_exists
    assert Parser.new
  end

  def test_that_parser_groups_by_location
    by_location = @parser.parse("./data/Kindergartners in full-day program.csv")

    assert_equal [{:location=>"BRIGHTON 27J", :timeframe=>"2007", :dataformat=>"Percent", :data=>"0.23818"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2006", :dataformat=>"Percent", :data=>"0.0596"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2005", :dataformat=>"Percent", :data=>"0.06289"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2004", :dataformat=>"Percent", :data=>"0.03559"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2008", :dataformat=>"Percent", :data=>"0.22484"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2009", :dataformat=>"Percent", :data=>"0.2"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2010", :dataformat=>"Percent", :data=>"0.32329"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2011", :dataformat=>"Percent", :data=>"0.345"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2012", :dataformat=>"Percent", :data=>"0.45649"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2013", :dataformat=>"Percent", :data=>"0.57684"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2014", :dataformat=>"Percent", :data=>"0.71988"}], by_location["BRIGHTON 27J"]
  end

  def test_clean_data_cleans_the_data
    data = [{:location=>"EAST YUMA COUNTY RJ-2", :timeframe=>"2014", :dataformat=>"Percent", :data=>"NA"},
            {:location=>"EATON RE-2", :timeframe=>"2010", :dataformat=>"Percent", :data=>"0.787"},
            {:location=>"BRIGHTON 27J", :timeframe=>"2004", :dataformat=>"Percent", :data=>nil},
            {:location=>"BRIGHTON 27J", :timeframe=>"2013", :dataformat=>"Percent", :data=>"0.57684"}]

    cleaned_data = [{:location=>"EATON RE-2", :timeframe=>"2010", :dataformat=>"Percent", :data=>"0.787"},
                  {:location=>"BRIGHTON 27J", :timeframe=>"2013", :dataformat=>"Percent", :data=>"0.57684"}]        
    
    assert_equal cleaned_data, @parser.clean_data(data)
  end

end
