class District

  attr_reader :name, :enrollment, :statewide_test, :economic_profile

  def initialize(name)
    @name = name[:name].upcase
  end

  def set_enrollment(enrollment)
    @enrollment = enrollment
  end

  def set_statewide_test(statewide_test)
    @statewide_test = statewide_test
  end

  def set_economic_profile(economic_profile)
    @economic_profile = economic_profile
  end

end
