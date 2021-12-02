require 'timeout'

files   = ARGV
counter = Hash.new { 0 }
trace   = TracePoint.new(:call, :c_call) { |tp| counter[tp.method_id] += 1 }
$stdout = File.open(File::NULL, 'w')

files.each do |file|
  f = File.open(file, 'r')

  begin
    Timeout.timeout(5) {
      trace.enable { eval f.read }
    }
  rescue Timeout::Error
  end

  f.close
end

$stdout = STDOUT

pp counter.sort_by { |_method, count| count }.reverse.to_h

# find ./ -name *.rb -newermt '20210101' | xargs ruby ~/til/activities/202112_tp_practice/counter.rb
