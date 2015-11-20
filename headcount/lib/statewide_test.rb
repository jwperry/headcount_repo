require 'pry'
require_relative 'district_repository'

class StatewideTest

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def name
    @data[:name]
  end

  def proficient_by_grade(grade)
    if grade_is_valid(grade)
      return query_hash_by_three(@data[:third_grade], :timeframe, [{:score => :data}]) if grade == 3
      return query_hash_by_three(@data[:eighth_grade], :timeframe, [{:score => :data}]) if grade == 8
    end
  end

  def proficient_by_race_or_ethnicity(race_or_ethnicity)
    if race_or_ethnicity_is_valid(race_or_ethnicity)
      math = query_hash_by_three_with_race_by_subject(race_or_ethnicity, :math, @data[:math], :timeframe, [{:score => :data}])
      reading = query_hash_by_three_with_race_by_subject(race_or_ethnicity, :reading, @data[:reading], :timeframe, [{:score => :data}])
      writing = query_hash_by_three_with_race_by_subject(race_or_ethnicity, :writing, @data[:writing], :timeframe, [{:score => :data}])
      math.merge(reading.merge(writing) { |k, v1, v2| v1.merge(v2) }) { |k, v1, v2| v1.merge(v2) }
    end
  end

  def proficient_for_subject_by_grade_in_year(score, grade, year)
    if score_is_valid(score) && grade_is_valid(grade)
      return truncate(get_data_for_subject_by_grade_in_year(score, :third_grade, year)) if grade == 3
      return truncate(get_data_for_subject_by_grade_in_year(score, :eighth_grade, year)) if grade == 8
    end
  end

  def proficient_for_subject_by_race_in_year(score, race_or_ethnicity, year)
    if score_is_valid(score) && race_or_ethnicity_is_valid(race_or_ethnicity)
      return truncate(get_data_for_subject_by_race_in_year(score, race_or_ethnicity, year))
    end
  end

  def grade_is_valid(grade)
    return @data.has_key?(:third_grade) if grade == 3
    return @data.has_key?(:eighth_grade) if grade == 8
    fail UnknownDataError
  end

  def race_or_ethnicity_is_valid(race_or_ethnicity)
    valid_races = [:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]
    return true if valid_races.include?(race_or_ethnicity.downcase)
    fail UnknownDataError
  end

  def score_is_valid(score)
    return @data.has_key?(:math) if score == :math
    return @data.has_key?(:reading) if score == :reading
    return @data.has_key?(:writing) if score == :writing
    fail UnknownDataError
  end

  def get_data_for_subject_by_grade_in_year(score, grade, year)
    @data[grade].each do | hash_row |
      return hash_row[:data] if hash_row[:score].downcase.to_sym == score && hash_row[:timeframe].to_i == year
    end
  end

  def get_data_for_subject_by_race_in_year(score, race_or_ethnicity, year)
    @data[score].each do | hash_row |
      return hash_row[:data]if hash_row[:race_ethnicity].downcase.to_sym == race_or_ethnicity && hash_row[:timeframe].to_i == year
    end
  end

  def query_hash_by_three(hash_array, group_by, columns)
    return_hash = {}
    hash_array.each do | hash_row |
      columns.each do | col |
        col.each do | key, value |
          return_hash = return_hash.merge({ hash_row[group_by].to_i => { hash_row[key].downcase.to_sym => truncate(hash_row[value]) }}) { |k, v1, v2| v1.merge(v2) }
        end
      end
    end
    return_hash
  end

  def query_hash_by_three_with_race_by_subject(race, subject, hash_array, group_by, columns)
    return_hash = {}
    hash_array.each do | hash_row |
      columns.each do | col |
        col.each do | key, value |
          if hash_row[:race_ethnicity].downcase == race.to_s
            return_hash = return_hash.merge({ hash_row[group_by].to_i => { subject => truncate(hash_row[value]) }}) { |k, v1, v2| v1.merge(v2) }
          end
        end
      end
    end
    return_hash
  end

  def year_over_year_avg(grade, subject, weighting = {:math => 1.0/3.0, :reading => 1.0/3.0, :writing => 1.0/3.0})
    if subject == :all
      math_read_write = get_weighted_avgs(grade, weighting)
      return nil if math_read_write.nil?
      return math_read_write
    else
      earliest_year = earliest_year_data(grade, subject)
      latest_year = latest_year_data(grade, subject)
      return nil if earliest_year.nil? || latest_year.nil?
      get_avg(earliest_year, latest_year)
    end
  end

  def earliest_year_data(grade, subject=:all)
    return nil if @data[grade].nil?
    subj_lines = @data[grade].select { |hash_row| hash_row[:score].downcase.to_sym == subject }
    subj_lines.sort_by!{|hash_row| hash_row[:timeframe]}
    return nil if subj_lines.empty?
    [subj_lines[0][:timeframe].to_f, subj_lines[0][:data].to_f]
  end

  def latest_year_data(grade, subject=:all)
    return nil if @data[grade].nil?
    subj_lines = @data[grade].select { |hash_row| hash_row[:score].downcase.to_sym == subject }
    subj_lines.sort_by!{|hash_row| hash_row[:timeframe]}
    return nil if subj_lines.empty?
    [subj_lines[-1][:timeframe].to_f, subj_lines[-1][:data].to_f]
  end

  def get_avg(earliest_data, latest_data)
    (latest_data[1] - earliest_data[1]) / (latest_data[0] - earliest_data[0])
  end

  def get_weighted_avgs(grade, weighting)
    math, reading, writing = math_data(grade), reading_data(grade), writing_data(grade)
    return nil unless [math, reading, writing].none?{ | n | n.nil? }
    math = math * weighting[:math]
    reading = reading * weighting[:reading]
    writing = writing * weighting[:writing]
    [math, reading, writing].compact.reduce(:+)
  end

  def math_data(grade)
    earliest_year = earliest_year_data(grade, :math)
    latest_year = latest_year_data(grade, :math)
    return nil if earliest_year.nil? || latest_year.nil?
    get_avg(earliest_year, latest_year)
  end

  def reading_data(grade)
    earliest_year = earliest_year_data(grade, :reading)
    latest_year = latest_year_data(grade, :reading)
    return nil if earliest_year.nil? || latest_year.nil?
    get_avg(earliest_year, latest_year)
  end

  def writing_data(grade)
    earliest_year = earliest_year_data(grade, :writing)
    latest_year = latest_year_data(grade, :writing)
    return nil if earliest_year.nil? || latest_year.nil?
    get_avg(earliest_year, latest_year)
  end

  def truncate(number)
    (number.to_f * 1000.0).to_i / 1000.0
  end

end