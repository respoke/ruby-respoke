module Respoke
  class Role
    attr_reader :id, :name
    attr_accessor :rules
    def initialize(client, id:, name:, **rules)
      @client = client
      @id = id
      @name = name
      @rules = rules
    end

    def save
      response = @client.update_role(id: @id, rules: @rules)
    end

    def delete
      response = @client.delete_role(id: @id)
    end
  end
end