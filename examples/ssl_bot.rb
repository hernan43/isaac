require '../lib/isaac.rb'

configure do |c|
  c.nick    = "ssh_echo_bot"
  c.server  = "localhost"
  c.port    = 6667
  c.verbose = true
  c.use_ssl = true
end

on :connect do
  join "#Awesome_Channel"
end

on :channel, // do
  msg channel, message
end
