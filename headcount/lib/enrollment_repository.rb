class EnrollmentRepository

  attr_reader :enrollments

  def initialize(dr = nil)
    @enrollments = []
    @dr = dr
  end

  def store_enrollment(data)
    if find_by_name(data[:name])
      find_by_name(data[:name]).data.merge!(data)
    else
      enroll = Enrollment.new(data)
      @dr.find_by_name(enroll.name).set_enrollment(enroll)
      @enrollments << enroll
    end
  end

  def find_by_name(district)
    @enrollments.each do | enrollment |
      return enrollment if enrollment.name.upcase == district.to_s.upcase
    end
    nil
  end

  def load_data(hash)
    if @dr.nil?
      @dr = DistrictRepository.new
      @dr.enrollment_repo = self
      @dr.load_data(hash)
    else
      @dr.formatter.distribute(hash)
    end
  end

end
