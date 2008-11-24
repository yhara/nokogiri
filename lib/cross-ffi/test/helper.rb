require 'rubygems'
require 'test/unit'
gem 'thoughtbot-shoulda'
require 'shoulda'
gem 'mocha'
require 'mocha'

class Test::Unit::TestCase
  def assert_fequal a, b
    assert (a - b).abs < 0.00001
  end

  def gc_everything
    10.times { GC.start }
  end
end
