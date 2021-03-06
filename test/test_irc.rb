require File.join(File.dirname(__FILE__), 'helper')

class TestIrc < Test::Unit::TestCase
  test "a new bot connects to IRC" do
    bot = mock_bot {}

    assert_equal "NICK isaac\n", @server.gets
    assert_equal "USER isaac 0 * :#{bot.config.realname}\n", @server.gets
  end

  test "password is sent if specified" do
    bot = mock_bot {
      configure {|c| c.password = "foo"}
    }
    assert_equal "PASS foo\n", @server.gets
  end

  test "no messages are sent when registration isn't complete" do
    bot = mock_bot {
      on(:connect) {raw "Connected!"}
    }
    2.times { @server.gets } # NICK / USER
    bot.dispatch :connect

    assert @server.empty?
  end

  test "no messages are sent until registration is complete" do
    bot = mock_bot {
      on(:connect) {raw "Connected!"}
    }
    2.times { @server.gets } # NICK / USER
    bot.dispatch :connect

    1.upto(4) {|i| @server.puts ":localhost 00#{i}"}
    assert_equal "Connected!\n", @server.gets
  end
end
