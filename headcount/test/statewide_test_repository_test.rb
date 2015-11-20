require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class StatewideTestRepositoryTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @str = @dr.statewide_test_repo
    @str.load_data({:statewide_testing => {
                                            :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                                            :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                                            :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
                                            :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
                                            :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
                                          }
                  })
  end

  def test_statewide_test_repository_class_exists
    assert @str
  end

  def test_statewide_test_repository_is_initialized_with_an_empty_statewide_tests_array
    str = StatewideTestRepository.new

    assert_equal [], str.statewide_tests
  end

  def test_statewide_test_repository_is_initialized_with_our_district_repo
    dr = DistrictRepository.new

    assert dr.statewide_test_repo
    assert_equal StatewideTestRepository, dr.statewide_test_repo.class
  end

  def test_store_statewide_test_method_stores_our_statewide_test_objects_for_multiple_files
    keys = [:name, :third_grade, :eighth_grade, :math, :reading, :writing]
    
    assert_equal keys, @str.statewide_tests.first.data.keys
  end

  def test_first_and_last_enrollment_objects_are_not_the_same_object
    refute_equal @str.statewide_tests[0].object_id, @str.statewide_tests[-1].object_id
  end

  def test_find_by_name_method_returns_nil_with_an_invalid_name
    assert_equal nil, @str.find_by_name("puppies")
  end

  def test_find_by_name_method_returns_nil_with_an_integer
    assert_equal nil, @str.find_by_name(44)
  end

  def test_find_by_name_method_returns_an_enrollment_object
    object = @str.find_by_name("Colorado")

    assert_equal StatewideTest, object.class
  end

  def test_find_by_name_is_case_insensitive
    assert_equal "Colorado", @str.find_by_name("ColORADo").name
  end

end
