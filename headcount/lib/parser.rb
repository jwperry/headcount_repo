require 'csv'
require 'pry'

class Parser

  def initialize
    @bad_shit = ["N/A", "NA", nil, "#DIV/0!", "#REF!", "LNE", "#VALUE!"]
  end

  def parse(path)
    csv_rows = CSV.open(path, {headers: true, header_converters: :symbol}).to_a
    rows = csv_rows.map { | r | r.to_hash }
    cleaned_hashes = clean_data(rows)
    cleaned_hashes.group_by { | h | h[:location] }
  end

  def clean_data(rows)
    cleaned_hashes = Array.new
    rows.each do | row |
      row.each do | k, v |
        cleaned_hashes << row if k == :data && !(@bad_shit.include?(v))
      end
    end
      cleaned_hashes
  end
end