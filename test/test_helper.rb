require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'
require 'mocha/minitest'

require 'scout_apm'
require 'statsd-instrument'
require 'scout_statsd'

class FakeUDPSocket
  def initialize
    @buffer = []
  end

  def send(message, *)
    @buffer.push [message]
  end

  def recv
    @buffer.shift
  end

  def to_s
    inspect
  end

  def inspect
    "<FakeUDPSocket: #{@buffer.inspect}>"
  end
end


