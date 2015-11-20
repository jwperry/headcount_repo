require 'pry'
require_relative 'district_repository'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
    @swt = @dr.statewide_test_repo.statewide_tests
  end

  def kindergarten_participation_rate_variation(dist1, dist2)
    d1_part = get_avg(get_kp_data(@dr.find_by_name(dist1)))
    d2_part = get_avg(get_kp_data(@dr.find_by_name(dist2[:against])))
    final = d1_part / d2_part
    truncate(final)
  end

  def kindergarten_participation_rate_variation_trend(dist1, dist2)
    trend = Hash.new
    d1_data = get_kp_data_with_year(@dr.find_by_name(dist1))
    d2_data = get_kp_data_with_year(@dr.find_by_name(dist2[:against]))
    d1_data.each { | k, v | trend[k] = truncate(d1_data[k] / d2_data[k]) }
    trend
  end

  def get_kp_data(dist)
    data_array = Array.new
    dist.enrollment.data[:kindergarten_participation].each do | k, v |
      data_array << v.to_f
    end
    data_array
  end

  def get_kp_data_with_year(dist)
    data_hash = Hash.new
    dist.enrollment.data[:kindergarten_participation].each do | k, v |
      data_hash[k] = v.to_f
    end
    data_hash
  end

  def kindergarten_participation_against_high_school_graduation(district)
    kp = kindergarten_participation_rate_variation(district, :against => "COLORADO")
    gr = high_school_graduation_rate_variation(district, :against => "COLORADO")
    truncate(kp/gr)
  end

  def high_school_graduation_rate_variation(dist1, dist2)
    d1_part = get_avg(get_hs_grad_data(@dr.find_by_name(dist1)))
    d2_part = get_avg(get_hs_grad_data(@dr.find_by_name(dist2[:against])))
    final = d1_part / d2_part
    truncate(final)
  end

  def get_hs_grad_data(dist)
    data_array = Array.new
    dist.enrollment.data[:high_school_graduation].each do | k, v |
      data_array << v.to_f
    end
    data_array
  end

  def kindergarten_participation_correlates_with_high_school_graduation(tag_and_location)
    if tag_and_location[:for] == 'STATEWIDE'
      districts = @dr.enrollment_repo.enrollments.map { | e | e }
      districts_with_correlation(districts) >= 0.7
    elsif tag_and_location.include?(:for)
      correlation = kindergarten_participation_against_high_school_graduation(tag_and_location[:for])
      correlation >= 0.6 && correlation <= 1.5
    elsif tag_and_location.include?(:across)
      districts = tag_and_location[:across].map { | n | @dr.enrollment_repo.find_by_name(n) }
      districts_with_correlation(districts) >= 0.7
    end
  end

  def districts_with_correlation(districts)
    names = Array.new
    correlated = Array.new
    districts.each { | dist | names << dist.name }
    names.each do | name |
      correlated << kindergarten_participation_correlates_with_high_school_graduation(:for => name)
    end
    correlated.count { | boolean | boolean == true } / correlated.length.to_f
  end

  def top_statewide_test_year_over_year_growth(grade_subj_hash)
    fail InsufficientInformationError, 'A grade must be provided to answer this question' unless grade_subj_hash.has_key?(:grade)
    fail UnknownDataError, 'Not a known grade' unless grade_subj_hash[:grade] == 3 || grade_subj_hash[:grade] == 8
    if grade_subj_hash.has_key?(:top)
      get_averages_with_multiple_leaders(grade_subj_hash, get_gradekey(grade_subj_hash[:grade]))
    elsif grade_subj_hash.has_key?(:subject)
      get_averages_with_single_leader(grade_subj_hash, get_gradekey(grade_subj_hash[:grade]))
    else
      get_averages_across_all_subjects(grade_subj_hash, get_gradekey(grade_subj_hash[:grade]))
    end
  end

  def get_gradekey(grade)
    return :third_grade if grade == 3
    return :eighth_grade if grade == 8
  end

  def get_averages_with_single_leader(grade_subj_hash, grade)
    all_avgs = @swt.map do |swt|
      [swt.name, swt.year_over_year_avg(grade, grade_subj_hash[:subject])]
    end
    avgs = all_avgs.select { | n | (n[1].is_a?(Float) && !n[1].nan?) }
    leader = (avgs.sort_by { | n | n[1] }.reverse)[0]
    leader[1] = truncate(leader[1])
    return leader
  end

  def get_averages_with_multiple_leaders(grade_subj_hash, grade)
    all_avgs = @swt.map do |swt|
      [swt.name, swt.year_over_year_avg(grade, grade_subj_hash[:subject])]
    end
    avgs = all_avgs.select { | n | (n[1].is_a?(Float) && !n[1].nan?) }
    sorted = (avgs.sort_by { | n | n[1] }.reverse)
    sorted.each { | n | n[1] = truncate(n[1]) }
    sorted.max_by(grade_subj_hash[:top]) { | n | n[1] }
  end

  def get_averages_across_all_subjects(grade_subj_hash, grade)
    all_avgs = @swt.map do |swt|
      weighting = {:math => 1.0/3.0, :reading => 1.0/3.0, :writing => 1.0/3.0}
      weighting = grade_subj_hash[:weighting] unless grade_subj_hash[:weighting].nil?
      [swt.name, swt.year_over_year_avg(grade, :all, weighting)]
    end
    avgs = all_avgs.select { | n | (n[1].is_a?(Float) && !n[1].nan?) }
    sorted = avgs.sort_by { | n | n[1] }
    [sorted[-1][0], truncate(sorted[-1][1])]
  end

  def get_avg(data)
    data.reduce(:+) / data.length
  end

  def truncate(number)
    (number.to_f * 1000).to_i / 1000.0
  end

end

class UnknownDataError < ArgumentError
end

class UnknownRaceError < ArgumentError
end

class InsufficientInformationError < ArgumentError
end
