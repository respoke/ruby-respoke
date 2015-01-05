require 'test_helper'

class Respoke::Response::TestSessionToken < Minitest::Test
  def test_can_create_new_instance
    instance = Respoke::Response::SessionToken.new

    assert_instance_of Respoke::Response::SessionToken, instance
  end
end
