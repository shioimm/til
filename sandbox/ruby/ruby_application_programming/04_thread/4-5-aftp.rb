# 引用: Rubyアプリケーションプログラミング P186

require 'thread'
require 'net/ftp'
require 'shellwords'

class AFTP
  PROMPT = "< "
  MAX_THREADS = 2

  def initialize(host, user, password)
    @host     = host
    @user     = user
    @password = password
    @ftp      = Net::FTP.new(host, user, password)
    @command  = {
      "pwd"    => method(:pwd),
      "cd"     => method(:cd),
      "ls"     => method(:ls),
      "dir"    => method(:dir),
      "get"    => method(:get),
      "abort"  => method(:abort),
      "status" => method(:status),
      "quit"   => method(:quit)
    }
    @seqno                 = 0
    @downloaders           = []
    @num_threads           = 0
    @num_threads_mutex     = Mutex.new
    @thread_available_cond = ConditionVariable.new
  end

  def run
    while line = readline(PROMPT)
      args = Shellwords.shellwords(line)
      cmd = args.shift

      unless @command.has_key?(cmd)
        $stderr.printf("unlnown command: %s\n", cmd)
        next
      end

      begin
        @command[cmd].call(*args)
      rescue
        $stderr.puts($!)
      end
    end
  end

  def readline(prompt)
    print prompt
    return gets
  end

  def pwd
    puts @ftp.pwd
  end

  def cd(dir)
    @ftp.chdir(dir)
    puts dir
  end

  def ls(*args)
    @ftp.list(*args) do |line|
      puts line
    end
  end

  def get(remote, local = File.basename(remote))
    Thread.start do
      dir = @ftp.dir
      downloader = Downloader.new(@host, @user, @password, dir, remote, local, @seqno)

      @downloaders.push downloader
      @seqno += 1

      begin
        @num_threads_mutex.synchronize do
          while @num_threads == MAX_THREADS
            @thread_available_cond.wait(@num_threads_mutex)
          end
          @num_threads += 1
        end
      end

      begin
        downloader.run
      rescue Abort
        printf("%d: aborted\n", downloader.seqno)
        print PROMPT
      rescue
        $stderr.puts($!)
        print PROMPT
      ensure
        @num_threads_mutex.synchronize do
          @num_threads -= 1
          @thread_available_cond.signal
        end
        @downloaders.delete(downloader)
      end
    end
  end

  def abort(seqno)
    seqno = seqno.to_i
    target = @downloaders.find { |d| d.seqno == seqno }

    unless target
      $stderr.printf("no such thread: %d\n", seqno)
      return
    end

    target.thread.raise(Abort.new)
  end

  def status
    for downloader in @downloaders
      puts downloader.info
    end
  end

  def quit
    for downloader in @downloaders
      downloader.thread.raise(Abort.new)
      downloader.thread.join
    end
    @ftp.quit
    @ftp.close
    exit
  end

  class Downloader
    attr_reader :seqno, :running, :thread

    def initialize(host, user, password, dir, remote, local, seqno)
      @ftp = Net::FTP.new(host, user, password)
      @ftp.chdir(dir)

      @remote     = remote
      @local      = local
      @seqno      = seqno
      @read_bytes = 0
      @running    = running
      @thread     = thread
    end

    def run
      @running = true
      printf("%d: started\n")
      print PROMPT

      begin
        @ftp.getbinaryfile(@remote, @local, 4096) do |data|
          @read_bytes += data.size
        end
        printf("%d: completed\n", @seqno)
        print PROMP
      rescue Abort
        @ftp.abort
        raise
      ensure
        @ftp.quit
        @ftp.close
      end
    end

    def info
      if @running
        return format("%d:%s: running -- %d bytes read", @seqno, File.basename(@remote), @read_bytes)
      else
        return format("%d:%s: waitig", @seqno, File.basename(@remote))
      end
    end

    class Abort < Exception
    end
  end
end

$stdout.sync = true

host = ARGV.shift

unless host
  print "host: "
  host = gets.chomp
end

print "user: "
user = gets.chomp

print "password: "
begin
  password = gets.chomp
ensure
  system('stty', '-echo')
end

print "\n"

begin
  aftp = AFTP.new(host, user, password)
  aftp.run
rescue
  $stderr.puts($!)
  exit(1)
end
