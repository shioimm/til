# 参照: dRubyによる分散・Webプログラミング
class BGColor
  def initialize
    @colors = ['#eeeeff', 'bbbbff']
    @count = -1
  end
  attr_accessor :colors

  def next_bgcolor
    @count += 1
    @count = 0 if @colors.size <= @count
    "bgcolor='#{@colors[@count]}'"
  end
  alias :to_s :next_bgcolor
end
