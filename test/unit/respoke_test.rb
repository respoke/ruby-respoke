require 'test_helper'

class TestRespoke < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Respoke::VERSION
  end
end
