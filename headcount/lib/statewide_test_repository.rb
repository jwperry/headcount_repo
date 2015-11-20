require 'pry'

class StatewideTestRepository

  attr_reader :statewide_tests

  def initialize(dr = nil)
    @statewide_tests = []
    @dr = dr
  end

  def store_statewide_test(district_data)
    if find_by_name(district_data[:name])
      find_by_name(district_data[:name]).data.merge!(district_data)
    else
      statewide_test = StatewideTest.new(district_data)
      @dr.find_by_name(statewide_test.name).set_statewide_test(statewide_test)
      @statewide_tests << statewide_test
    end
  end

  def find_by_name(district)
    @statewide_tests.each do | statewide_test |
      return statewide_test if statewide_test.name.upcase == district.to_s.upcase
    end
    nil
  end

  def load_data(hash)
    if @dr.nil?
      @dr = DistrictRepository.new
      @dr.statewide_test_repo = self
      @dr.load_data(hash)
    else
      @dr.formatter.distribute(hash)
    end
  end

end
