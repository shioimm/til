require 'timeout'

files   = ARGV
counter = Hash.new { 0 }
trace   = TracePoint.new(:call, :c_call) { |tp| counter["#{tp.method_id} (#{tp.defined_class})"] += 1 }
$stdout = File.open(File::NULL, 'w')

files.each do |file|
  f = File.open(file, 'r')

  begin
    Timeout.timeout(5) {
      trace.enable { eval f.read }
    }
  rescue StandardError, LoadError
  end

  f.close
end

$stdout = STDOUT

most_used_methods_20 = counter.sort_by { |_method, count| count }.reverse.first(20)

pp most_used_methods_20.to_h
puts "#{most_used_methods_20[0][0]}、本年は大変お世話になりました。\n来年もよろしくお願いします。"

# find ./ -name *.rb -newermt '20210101' | xargs ruby ~/til/activities/202112_tp_practice/counter.rb
