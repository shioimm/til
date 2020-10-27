# Kindergarten Garden from https://exercism.io

class Garden
  STUDENTS = %w[Alice Bob Charlie David Eve Fred Ginny Harriet Ileana Joseph Kincaid Larry].freeze
  PLANTS   = { radishes: 'R', clover: 'C', grass: 'G', violets: 'V' }.invert.freeze

  def initialize(seeds, students = STUDENTS)
    @first_row, @second_row = seeds.split("\n").map(&:chars)
    @students = students.map{ |student| student.downcase.to_sym }.sort
  end

  def method_missing(name)
    students.include?(name) ? plants[students.index(name)].chars.map(&PLANTS) : super
  end

  private

    attr_reader :first_row, :second_row, :students

    def plants
      (first_row.zip second_row).each_slice(2)
                                .map { |first, second| (first.zip second).join }
    end
end
