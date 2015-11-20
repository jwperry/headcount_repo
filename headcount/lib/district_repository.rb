require 'pry'
require_relative 'district'
require_relative 'enrollment_repository'
require_relative 'enrollment'
require_relative 'statewide_test_repository'
require_relative 'statewide_test'
require_relative 'economic_profile_repository'
require_relative 'economic_profile'
require_relative 'parser'
require_relative 'formatter'
require_relative 'headcount_analyst'

class DistrictRepository

  attr_reader :districts, :formatter
  attr_accessor :enrollment_repo, :statewide_test_repo, :economic_profile_repo

  def initialize
    @districts = []
    @enrollment_repo = EnrollmentRepository.new(self)
    @statewide_test_repo = StatewideTestRepository.new(self)
    @economic_profile_repo = EconomicProfileRepository.new(self)
    @formatter = Formatter.new(self)
    build_districts
  end

  def build_districts
    CSV.open("./data/Kindergartners in full-day program.csv", headers: true).each do |row|
      if @districts.include?(find_by_name(row["Location"].upcase))
        next
      else
        @districts << District.new({:name => row["Location"].upcase})
      end
    end
  end

  def find_by_name(district)
    @districts.each do | d |
      if d.name == district.to_s.upcase
        return d
      end
    end
    return nil
  end

  def find_all_matching(string)
    matches = @districts.map do | d |
      d if d.name.include?(string.to_s.upcase)
    end
    matches.length == 0 ? [] : matches.compact
  end

  def load_data(hash)
    @formatter.distribute(hash)
  end

end