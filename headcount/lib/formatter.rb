require 'pry'

class Formatter

  def initialize(dr)
    @dr = dr
    @parser = Parser.new
    @formatters = {
                    :kindergarten => :kindergarten_formatter,
                    :high_school_graduation => :high_school_graduation_formatter,
                    :third_grade => :third_grade_formatter,
                    :eighth_grade => :eighth_grade_formatter,
                    :math => :math_formatter,
                    :reading => :reading_formatter,
                    :writing => :writing_formatter,
                    :median_household_income => :median_household_income_formatter,
                    :children_in_poverty => :children_in_poverty_formatter,
                    :free_or_reduced_price_lunch => :free_or_reduced_price_lunch_formatter,
                    :title_i => :title_i_formatter
                  }
  end

  def distribute(hash)
    hash.each do | category, path_hash |
      hash[category].each do | file_tag, path |
        formatted = call_formatter(file_tag, @parser.parse(path))
        formatted.each do | formatted_hash |
          package(category, formatted_hash)
        end
      end
    end
  end

  def call_formatter(file_tag, parsed_data)
    method(@formatters[file_tag]).call(parsed_data)
  end

  def package(category, formatted_hash)
    if category == :enrollment
      @dr.enrollment_repo.store_enrollment(formatted_hash)
    elsif category == :statewide_testing
      @dr.statewide_test_repo.store_statewide_test(formatted_hash)
    elsif category == :economic_profile
      @dr.economic_profile_repo.store_economic_profiles(formatted_hash)
    end
  end

  def extract_years_from_district_rows(rows)
    years = {}
    rows.each do | hash |
      year = hash[:timeframe].to_i
      data = hash[:data].to_f
      years[year] = data
    end
    years
  end

  def kindergarten_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :kindergarten_participation => extract_years_from_district_rows(dist_rows)}
    end
    formatted
  end

  def high_school_graduation_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :high_school_graduation => extract_years_from_district_rows(dist_rows)}
    end
    formatted
  end

  def third_grade_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :third_grade => dist_rows}
     end
     formatted
  end

  def eighth_grade_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :eighth_grade => dist_rows}
     end
     formatted
  end

  def math_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :math => dist_rows}
     end
     formatted
  end

  def reading_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :reading => dist_rows}
     end
     formatted
  end

  def writing_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :writing => dist_rows}
     end
     formatted
  end

  def median_household_income_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :median_household_income => dist_rows}
    end
    formatted
  end

  def children_in_poverty_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :children_in_poverty => dist_rows}
    end
    formatted
  end

  def free_or_reduced_price_lunch_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :free_or_reduced_price_lunch => dist_rows}
    end
    formatted
  end

  def title_i_formatter(parsed_data)
    formatted = parsed_data.map do | dist_name, dist_rows |
      {:name => dist_name,
       :title_i => dist_rows}
    end
    formatted
  end

end
