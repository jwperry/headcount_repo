require 'pry'

require_relative 'district_repository'


dr = DistrictRepository.new
ha = HeadcountAnalyst.new(dr)
str = dr.statewide_test_repo
epr = dr.economic_profile_repo

epr.load_data({
    :economic_profile => {
                          :median_household_income => "./data/Median household income.csv",
                          :children_in_poverty => "./data/School-aged children in poverty.csv",
                          :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
                          :title_i => "./data/Title I students.csv"
                         }
             })
ep = epr.find_by_name("ACADEMY 20")
# puts ep.estimated_median_household_income_in_year(2008)
# puts ep.median_household_income_average
# puts ep.children_in_poverty_in_year(2012)
# puts "We want .12743"
# puts ep.free_or_reduced_price_lunch_percentage_in_year(2014)
# puts ep.free_or_reduced_price_lunch_number_in_year(2012)
puts ep.title_i_in_year(2014)
"We want 0.0273"