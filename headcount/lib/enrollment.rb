class Enrollment

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def name
    @data[:name]
  end

  def kindergarten_participation_by_year
    @data[:kindergarten_participation].each do | k, v |
      @data[:kindergarten_participation][k] = truncate(v)
    end
  end

  def kindergarten_participation_in_year(year)
    if @data[:kindergarten_participation].include?(year)
      truncate(@data[:kindergarten_participation][year])
    else
      return nil
    end
  end

  def graduation_rate_by_year
    @data[:high_school_graduation].each do | k, v |
      @data[:high_school_graduation][k] = truncate(v)
    end
  end

  def graduation_rate_in_year(year)
    if @data[:high_school_graduation].include?(year)
      truncate(@data[:high_school_graduation][year])
    else
      return nil
    end
  end

  def truncate(number)
    (number.to_f * 1000).to_i / 1000.0
  end

end
