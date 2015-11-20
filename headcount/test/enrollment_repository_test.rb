require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class EnrollmentRepositoryTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @er = @dr.enrollment_repo
    @dr.load_data({ :enrollment =>
                    { :kindergarten =>           "./data/Kindergartners in full-day program.csv",
                      :high_school_graduation => "./data/High school graduation rates.csv"
                    }
                  })
  end

  def test_enrollment_repository_class_exists
    assert @er
  end

  def test_enrollment_repository_is_initialized_with_an_empty_enrollment_array
    er = EnrollmentRepository.new

    assert_equal [], er.enrollments
  end

  def test_enrollment_repository_is_initialized_with_our_district_repo
    dr = DistrictRepository.new

    assert dr.enrollment_repo
    assert_equal EnrollmentRepository, dr.enrollment_repo.class
  end

  def test_store_enrollment_method_stores_our_enrollment_objects_for_multiple_files
    assert_equal Enrollment, @er.enrollments[0].class
    assert_equal "WRAY SCHOOL DISTRICT RD-2", @er.enrollments[-2].name

    assert_equal({:name => "YUMA SCHOOL DISTRICT 1",
                  :kindergarten_participation => { 2007=>1, 2006=>1, 2005=>1,
                                                   2004=>0, 2008=>1, 2009=>1,
                                                   2010=>1, 2011=>1, 2012=>1,
                                                   2013=>1, 2014=>1 },
                  :high_school_graduation =>     { 2010=>0.903, 2011=>0.891,
                                                   2012=>0.85455, 2013=>0.88333,
                                                   2014=>0.91 }
                  }, @er.enrollments[-1].data)
  end

  def test_first_and_last_enrollment_objects_are_not_the_same_object
    refute_equal @er.enrollments[0].object_id, @er.enrollments[-1].object_id
  end

  def test_find_by_name_method_returns_nil_with_an_invalid_name
    assert_equal nil, @er.find_by_name("puppies")
  end

  def test_find_by_name_method_returns_nil_with_an_integer
    assert_equal nil, @er.find_by_name(44)
  end

  def test_find_by_name_method_returns_an_enrollment_object
    object = @er.find_by_name("Colorado")

    assert_equal Enrollment, object.class
  end

  def test_find_by_name_is_case_insensitive
    assert_equal "Colorado", @er.find_by_name("ColORADo").name
  end

end
