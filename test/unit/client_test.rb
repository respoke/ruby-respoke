require 'test_helper'

class Respoke::TestClient < MiniTest::Test
  def setup
    @client = Respoke::Client.new
  end

  def test_can_create_new_client
    assert_instance_of Respoke::Client, @client
  end

  def test_can_set_app_secret_on_initialization
    secret = 'foo'
    client = Respoke::Client.new(app_secret: secret)

    assert_equal secret, client.app_secret
  end

  def test_cannot_set_app_secret_by_attribute
    secret = 'foo'

    assert_raises NoMethodError do
      @client.app_secret = secret
    end
  end

  def test_has_default_base_url
    assert_equal Respoke::Client::DEFAULT_BASE_URL, @client.base_url
  end

  def test_can_override_base_url
    url = 'https://localhost:2000'
    client = Respoke::Client.new(base_url: url)

    assert_equal url, client.base_url
  end

  def test_cannot_set_base_url_by_attribute
    assert_raises NoMethodError do
      @client.base_url = 'https://localhost:2000'
    end
  end
end
