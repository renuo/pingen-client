require "json"

module Pingen
  class Response
    attr_accessor :json, :code

    def self.from(response)
      new(JSON.parse(response.body, symbolize_names: true), response.code.to_i)
    rescue JSON::ParserError
      new(response.body, response.code.to_i)
    end

    def initialize(json, code)
      @json = json
      @code = code
    end

    def ok?
      code == 200
    end
  end
end
