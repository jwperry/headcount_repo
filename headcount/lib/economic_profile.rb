require 'pry'
require_relative 'district_repository'

class EconomicProfile

  attr_reader :data

  def initialize(data)
    if !data[:name].nil?
      @data = data
    else
      @data = fix_formatting(data)
    end
  end

  def name
    @data[:name]
  end

  def estimated_median_household_income_in_year(year)
    fail UnknownDataError unless year_is_valid_with_range(year)
    data_for_years = @data[:median_household_income].map do | hash_row |
      hash_row[:data].to_i if get_year_range(hash_row[:timeframe]).include?(year)
    end
    data_for_years = data_for_years.compact
    truncate(data_for_years.compact.reduce(:+)/data_for_years.length)
  end

  def median_household_income_average
    data_for_years = @data[:median_household_income].map do | hash_row |
      hash_row[:data].to_f
    end
    data_for_years = data_for_years.compact
    truncate(data_for_years.compact.reduce(:+)/data_for_years.length)
  end

  def children_in_poverty_in_year(year)
    fail UnknownDataError unless year_is_valid_with_percent(year)
    percent_years = @data[:children_in_poverty].map do | hash_row |
      hash_row[:data].to_f if hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Percent"
    end
    truncate(percent_years.compact.reduce(:+))
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    fail UnknownDataError unless year_is_valid_for_free_or_reduced_lunch_percent(year)
    percent_years = @data[:free_or_reduced_price_lunch].map do | hash_row |
      hash_row[:data].to_f if hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Percent" && hash_row[:poverty_level] == "Eligible for Free or Reduced Lunch"
    end
    truncate(percent_years.compact.reduce(:+))
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    fail UnknownDataError unless year_is_valid_for_free_or_reduced_lunch_num(year)
    num_years = @data[:free_or_reduced_price_lunch].map do | hash_row |
      hash_row[:data].to_f if hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Number" && hash_row[:poverty_level] == "Eligible for Free or Reduced Lunch"
    end
    truncate(num_years.compact.reduce(:+))
  end

  def title_i_in_year(year)
    fail UnknownDataError unless year_is_valid_for_title_i(year)
    percent_years = @data[:title_i].map do | hash_row |
      hash_row[:data].to_f if hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Percent"
    end
    truncate(percent_years.compact.reduce(:+))
  end

  def year_is_valid_with_range(year)
    @data[:median_household_income].any? do | hash_row |
      year_range = get_year_range(hash_row[:timeframe])
      year_range.include?(year)
    end
  end

  def year_is_valid_with_percent(year)
    @data[:children_in_poverty].any? do | hash_row |
      hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Percent"
    end
  end

  def year_is_valid_for_free_or_reduced_lunch_percent(year)
    @data[:free_or_reduced_price_lunch].any? do | hash_row |
      hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Percent" && hash_row[:poverty_level] == "Eligible for Free or Reduced Lunch"
    end
  end

  def year_is_valid_for_free_or_reduced_lunch_num(year)
    @data[:free_or_reduced_price_lunch].any? do | hash_row |
      hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Number" && hash_row[:poverty_level] == "Eligible for Free or Reduced Lunch"
    end
  end

  def year_is_valid_for_title_i(year)
    @data[:title_i].any? do | hash_row |
      hash_row[:timeframe].to_f == year && hash_row[:dataformat] == "Percent"
    end
  end

  def get_year_range(timeframe)
    years = timeframe.split("-")
    (years[0].to_f..years[1].to_f)
  end

  def truncate(number)
    (number.to_f * 1000.0).to_i / 1000.0
  end

  def fix_formatting(data)
    data_hash = {}
    data_hash.merge!({:median_household_income => get_formatted_median(data)})
    data_hash.merge!({:children_in_poverty => get_formatted_children(data)})
    data_hash.merge!({:free_or_reduced_price_lunch => get_formatted_lunch(data)})
    data_hash.merge!({:title_i => get_formatted_title_i(data)})
    return data_hash
  end

  def get_formatted_median(data)
    return_array = []
    data[:median_household_income].each do | k, v |
      return_array << {:location => nil, :timeframe => "#{k[0]}-#{k[1]}", :dataformat => "Currency", :data => v.to_s}
    end
    return_array
  end

  def get_formatted_children(data)
    return_array = []
    data[:children_in_poverty].each do | k, v |
      return_array << {:location => nil, :timeframe => k.to_s, :dataformat => "Percent", :data => v.to_s}
    end
    return_array
  end

  def get_formatted_lunch(data)
    return_array = []
    data[:free_or_reduced_price_lunch].each do | k, v |
      return_array << {:location => nil, :poverty_level => "Eligible for Free or Reduced Lunch", :timeframe => k.to_s, :dataformat => "Percent", :data => v[:percentage].to_s}
      return_array << {:location => nil, :poverty_level => "Eligible for Free or Reduced Lunch", :timeframe => k.to_s, :dataformat => "Number", :data => v[:total].to_s}
    end
    return_array
  end

  def get_formatted_title_i(data)
    return_array = []
    data[:title_i].each do | k, v |
      return_array << {:location => nil, :timeframe => k.to_s, :dataformat => "Percent", :data => v.to_s}
    end
    return_array
  end

end
