require 'test_helper'

class Respoke::Response::TestSessionTokenId < Minitest::Test
  def setup
    @klass = Respoke::Response::SessionTokenId
  end

  def test_can_create_new_instance
    response = @klass.new

    assert_instance_of @klass, response
  end

  def test_coerces_createdAt_to_utc_Time
    response = @klass.new(
      createdAt: '2015-01-02T21:30:57.714Z'
    )

    assert_instance_of Time, response.createdAt
    assert response.createdAt.utc?
  end

  def test_coerces_expiryTime_to_utc_Time
    response = @klass.new(
      expiryTime: 1420320657
    )

    assert_instance_of Time, response.expiryTime
    assert response.expiryTime.utc?
  end

  def test_coerces_createTime_to_utc_Time
    response = @klass.new(
      createTime: 1420320657
    )

    assert_instance_of Time, response.createTime
    assert response.createTime.utc?
  end
end
