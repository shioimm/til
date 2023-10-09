# プログラミングElixir 6.5 ModuleAndFunctions-5

class Chop
  def guess(actual, range)
    tmp = ((range.min + range.max) / 2).ceil

    puts "Is it #{tmp}"

    return puts actual if tmp.eql? actual

    if actual > tmp
      guess(actual, tmp..range.last)
    elsif actual < tmp
      guess(actual, range.first..tmp)
    end
  end
end

Chop.new.guess(273, (1..1000))
