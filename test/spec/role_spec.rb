
require 'test_helper'

describe "Roles" do
  let :client do
    Respoke::Client.new(app_secret: TestConfig.app_secret)
  end

  let :existing_role do
    client.create_role(name: SecureRandom::uuid(), rules: {})
  end

  it "creates a role" do
    VCR.use_cassette 'create_role' do
      role_name = SecureRandom::uuid()
      role = client.create_role(name: role_name, rules: { mediaRelay: false })
      assert !role.id.nil?
    end
  end

  it "finds a role" do
    VCR.use_cassette 'find_role' do
      response = client.find_role(id: existing_role.id)
      assert (response.name == existing_role.name) && (existing_role.id == existing_role.id)
    end
  end

  it "updates a role" do
    VCR.use_cassette 'update_role' do
      assert existing_role.rules[:mediaRelay] == false
      existing_role.rules[:mediaRelay]=true
      existing_role.save
      assert (client.find_role(id: existing_role.id).rules[:mediaRelay] == true)
    end
  end

  it "deletes a role" do
    VCR.use_cassette 'delete_a_role' do
      existing_role.delete
      assert client.find_role(id: existing_role.id).nil?
    end
  end

  describe "with bulk retrieved roles" do
    before :each do
      VCR.use_cassette 'bulk_roles' do
        2.times { client.create_role(name: SecureRandom::uuid(), rules:{}) }
      end
    end

    let :retrieved_roles do
      client.roles()
    end

    it "can delete" do
      VCR.use_cassette 'delete a retrieved role' do
        first_id = retrieved_roles.first.id
        retrieved_roles.first.delete()
        assert !client.roles().map(&:id).include?(first_id)
      end
    end

    it "can be updates" do
      VCR.use_cassette 'update a retrieved role' do
        role = retrieved_roles.first
        assert role.rules[:mediaRelay] == false
        role.rules[:mediaRelay]=true
        role.save
        assert (client.roles().first.rules[:mediaRelay] == true)
      end
    end
  end
end
