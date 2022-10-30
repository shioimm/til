File.open(ARGV[0], "r+") do |f|
  f.flock(File::LOCK_EX)
  f.rewind;
  body = f.read;
  body = body.gsub("++", "+= 1")
  f.rewind;
  f.puts body; # 別ファイルを作って実行し、削除するようにする
  f.truncate(f.tell);
end
