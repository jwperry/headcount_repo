require 'pry'

class EconomicProfileRepository

  attr_reader :economic_profiles

  def initialize(dr = nil)
    @economic_profiles = []
    @dr = dr
  end

  def store_economic_profiles(district_data)
    if find_by_name(district_data[:name])
      find_by_name(district_data[:name]).data.merge!(district_data)
    else
      economic_profile = EconomicProfile.new(district_data)
      @dr.find_by_name(economic_profile.name).set_economic_profile(economic_profile)
      @economic_profiles << economic_profile
    end
  end

  def find_by_name(district)
    @economic_profiles.each do | economic_profile |
      return economic_profile if economic_profile.name.upcase == district.to_s.upcase
    end
    nil
  end

  def load_data(hash)
    if @dr.nil?
      @dr = DistrictRepository.new
      @dr.economic_profile_repo = self
      @dr.load_data(hash)
    else
      @dr.formatter.distribute(hash)
    end
  end

end
