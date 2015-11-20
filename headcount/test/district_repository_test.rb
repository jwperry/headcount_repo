require 'minitest/autorun'
require 'minitest/emoji'
require './lib/district_repository'

class DistrictRepositoryTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
  end

  def test_district_repository_class_exists
    assert DistrictRepository.new
  end

  def test_districts_hash_receives_all_districts_upon_initialize
    assert_equal 181, @dr.districts.length
  end

  def test_build_districts
    names = @dr.districts.map { | d | d.name }

    assert_equal names, [ "COLORADO", "ACADEMY 20", "ADAMS COUNTY 14","ADAMS-ARAPAHOE 28J",
                          "AGATE 300", "AGUILAR REORGANIZED 6", "AKRON R-1", "ALAMOSA RE-11J",
                          "ARCHULETA COUNTY 50 JT", "ARICKAREE R-2", "ARRIBA-FLAGLER C-20",
                          "ASPEN 1", "AULT-HIGHLAND RE-9", "BAYFIELD 10 JT-R", "BENNETT 29J",
                          "BETHUNE R-5", "BIG SANDY 100J", "BOULDER VALLEY RE 2", "BRANSON REORGANIZED 82",
                          "BRIGGSDALE RE-10", "BRIGHTON 27J", "BRUSH RE-2(J)", "BUENA VISTA R-31",
                          "BUFFALO RE-4", "BURLINGTON RE-6J", "BYERS 32J", "CALHAN RJ-1",
                          "CAMPO RE-6", "CANON CITY RE-1", "CENTENNIAL R-1", "CENTER 26 JT",
                          "CHERAW 31", "CHERRY CREEK 5", "CHEYENNE COUNTY RE-5", "CHEYENNE MOUNTAIN 12",
                          "CLEAR CREEK RE-1", "COLORADO SPRINGS 11", "COTOPAXI RE-3", "CREEDE CONSOLIDATED 1",
                          "CRIPPLE CREEK-VICTOR RE-1", "CROWLEY COUNTY RE-1-J", "CUSTER COUNTY SCHOOL DISTRICT C-1",
                          "DE BEQUE 49JT", "DEER TRAIL 26J", "DEL NORTE C-7", "DELTA COUNTY 50(J)",
                          "DENVER COUNTY 1", "DOLORES COUNTY RE NO.2", "DOLORES RE-4A", "DOUGLAS COUNTY RE 1",
                          "DURANGO 9-R", "EADS RE-1", "EAGLE COUNTY RE 50", "EAST GRAND 2",
                          "EAST OTERO R-1", "EAST YUMA COUNTY RJ-2", "EATON RE-2", "EDISON 54 JT",
                          "ELBERT 200", "ELIZABETH C-1", "ELLICOTT 22", "ENGLEWOOD 1", "FALCON 49",
                          "FLORENCE RE-2", "FORT MORGAN RE-3", "FOUNTAIN 8", "FOWLER R-4J",
                          "FRENCHMAN RE-3", "GARFIELD 16", "GARFIELD RE-2", "GENOA-HUGO C113",
                          "GILPIN COUNTY RE-1", "GRANADA RE-1", "GREELEY 6", "GUNNISON WATERSHED RE1J",
                          "HANOVER 28", "HARRISON 2", "HAXTUN RE-2J", "HAYDEN RE-1", "HINSDALE COUNTY RE 1",
                          "HI-PLAINS R-23", "HOEHNE REORGANIZED 3", "HOLLY RE-3", "HOLYOKE RE-1J",
                          "HUERFANO RE-1", "IDALIA SCHOOL DISTRICT RJ-3", "IGNACIO 11 JT", "JEFFERSON COUNTY R-1",
                          "JOHNSTOWN-MILLIKEN RE-5J", "JULESBURG RE-1", "KARVAL RE-23", "KEENESBURG RE-3(J)",
                          "KIM REORGANIZED 88", "KIOWA C-2", "KIT CARSON R-1", "LA VETA RE-2",
                          "LAKE COUNTY R-1", "LAMAR RE-2", "LAS ANIMAS RE-1", "LEWIS-PALMER 38",
                          "LIBERTY SCHOOL DISTRICT J-4", "LIMON RE-4J", "LITTLETON 6", "LONE STAR 101",
                          "MANCOS RE-6", "MANITOU SPRINGS 14", "MANZANOLA 3J", "MAPLETON 1",
                          "MC CLAVE RE-2", "MEEKER RE1", "MESA COUNTY VALLEY 51", "MIAMI/YODER 60 JT",
                          "MOFFAT 2", "MOFFAT COUNTY RE:NO 1", "MONTE VISTA C-8", "MONTEZUMA-CORTEZ RE-1",
                          "MONTROSE COUNTY RE-1J", "MOUNTAIN VALLEY RE 1", "NORTH CONEJOS RE-1J",
                          "NORTH PARK R-1", "NORTHGLENN-THORNTON 12", "NORWOOD R-2J", "OTIS R-3",
                          "OURAY R-1", "PARK (ESTES PARK) R-3", "PARK COUNTY RE-2", "PAWNEE RE-12",
                          "PEYTON 23 JT", "PLAINVIEW RE-2", "PLATEAU RE-5", "PLATEAU VALLEY 50",
                          "PLATTE CANYON 1", "PLATTE VALLEY RE-3", "PLATTE VALLEY RE-7", "POUDRE R-1",
                          "PRAIRIE RE-11", "PRIMERO REORGANIZED 2", "PRITCHETT RE-3", "PUEBLO CITY 60",
                          "PUEBLO COUNTY RURAL 70", "RANGELY RE-4", "RIDGWAY R-2", "ROARING FORK RE-1",
                          "ROCKY FORD R-2", "SALIDA R-32", "SANFORD 6J", "SANGRE DE CRISTO RE-22J",
                          "SARGENT RE-33J", "SHERIDAN 2", "SIERRA GRANDE R-30", "SILVERTON 1",
                          "SOUTH CONEJOS RE-10", "SOUTH ROUTT RE 3", "SPRINGFIELD RE-4", "ST VRAIN VALLEY RE 1J",
                          "STEAMBOAT SPRINGS RE-2", "STRASBURG 31J", "STRATTON R-4", "SUMMIT RE-1",
                          "SWINK 33", "TELLURIDE R-1", "THOMPSON R-2J", "TRINIDAD 1", "VALLEY RE-1", "VILAS RE-5",
                          "WALSH RE-1", "WELD COUNTY RE-1", "WELD COUNTY S/D RE-8", "WELDON VALLEY RE-20(J)",
                          "WEST END RE-2", "WEST GRAND 1-JT", "WEST YUMA COUNTY RJ-1", "WESTMINSTER 50",
                          "WIDEFIELD 3", "WIGGINS RE-50(J)", "WILEY RE-13 JT", "WINDSOR RE-4",
                          "WOODLAND PARK RE-2", "WOODLIN R-104", "WRAY SCHOOL DISTRICT RD-2", "YUMA SCHOOL DISTRICT 1" ]
  end

  def test_find_by_name_is_case_insensitive
    assert_equal "COLORADO", @dr.find_by_name("ColORadO").name
  end

  def test_find_by_name_returns_nil_with_an_invalid_name
    assert_equal nil, @dr.find_by_name("Zombies")
  end

  def test_find_by_name_returns_nil_when_there_is_no_name
    assert_equal nil, @dr.find_by_name("")
  end

  def test_find_by_name_returns_nil_when_a_number_is_passed_in
    assert_equal nil, @dr.find_by_name(23)
  end

  def test_find_by_name_returns_a_district_object
    object = @dr.find_by_name("Colorado")

    assert_equal District, object.class
  end

  def test_find_all_matching_returns_district_name_matches
    districts = @dr.find_all_matching("Colorado")
    matches = districts.map { | d | d.name }

    assert_equal ["COLORADO", "COLORADO SPRINGS 11"], matches
  end

  def test_find_all_matching_works_with_a_name_fragment
    districts = @dr.find_all_matching("ca")
    matches = districts.map { |d| d.name }

    assert_equal ["ACADEMY 20", "CALHAN RJ-1",
                  "CAMPO RE-6", "CANON CITY RE-1",
                  "KIT CARSON R-1", "PLATTE CANYON 1"], matches
  end

  def test_find_all_matching_returns_an_empty_array_with_an_invalid_entry
    districts = @dr.find_all_matching("poop")

    assert_equal [], districts
  end

  def test_find_all_matching_returns_an_empty_array_with_blank_spaces
    districts = @dr.find_all_matching("  ")

    assert_equal [], districts
  end

  def test_find_all_matching_returns_an_empty_array_with_an_invalid_number
    districts = @dr.find_all_matching(45)

    assert_equal [], districts
  end

  def test_find_all_matching_works_with_a_valid_number
    districts = @dr.find_all_matching(20)
    matches = districts.map { |d| d.name }

    assert_equal ["ACADEMY 20", "ARRIBA-FLAGLER C-20",
                 "ELBERT 200", "WELDON VALLEY RE-20(J)"], matches
  end

end
