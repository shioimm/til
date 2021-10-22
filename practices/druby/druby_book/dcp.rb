# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

class DCP
  include DRbUndumped

  def size(fname)
    File.lstat(fname).size
  end

  def fetch(fname)
    File.open(fname, 'rb') do |fp|
      while buf = fp.read(4096)
        yield buf
      end
    end
  end

  def store_from(there, fname)
    size = there.size(fname)
    wrote = 0

    File.open(fname, 'wb') do |fp|
      there.fetch(fname) do |buf|
        wrote += fp.write(buf)
        yield([wrote, size]) if block_given?
        nil
      end
    end

    wrote
  end

  def copy(uri, fname)
    there = DRbObject.new_with_uri(uri)
    store_from(there, fname) do |wrote, size|
      puts "#{wrote * 100 / size}"
    end
  end
end

if __FILE__ == $0
  if ARGV[0] == '-server'
    ARGV.shift
    DRb.start_service(ARGV.shift, DCP.new)
    puts DRb.uri
    DRb.thread.join
  else
    uri = ARGV.shift
    fname = ARGV.shift
    raise('usage: dcp.rb URI filename') if uri.nil? || fname.nil?
    DRb.start_service
    DCP.new.copy(uri, fname)
  end
end
