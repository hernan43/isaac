require 'rubygems'
require 'test/unit'
require 'contest'
require 'rr'
require 'lib/isaac'
require 'timeout'
begin
  require 'ruby-debug'
rescue LoadError; end

module Test::Unit::Assertions
  def assert_empty_buffer(io)
    assert_raise(Errno::EAGAIN) { io.read_nonblock 1 }
  end
end

class MockSocket
  def self.pipe
    socket1, socket2 = new, new
    socket1.in, socket2.out = IO.pipe
    socket2.in, socket1.out = IO.pipe
    [socket1, socket2]
  end

  attr_accessor :in, :out
  def gets()
    Timeout.timeout(1) {@in.gets}
  end
  def puts(m) @out.puts(m) end
  def print(m) @out.write(m) end
  def eof?() @in.eof? end
  def empty?
    begin
      @in.read_nonblock(1)
      false
    rescue Errno::EAGAIN
      true
    end
  end
end

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def mock_bot(&b)
    @socket, @server = MockSocket.pipe
    stub(TCPSocket).open(anything, anything) {@socket}
    bot = Isaac::Bot.new(&b)
    bot.config.environment = :test
    Thread.start { bot.start }
    bot
  end

  def bot_is_connected
    assert_equal "NICK isaac\n", @server.gets
    assert_equal "USER isaac 0 * :Isaac\n", @server.gets
    1.upto(4) {|i| @server.puts ":localhost 00#{i}"}
  end
end
