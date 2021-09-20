module Pingen
  class Sends
    def initialize(client = Client.new)
      @client = client
    end

    def list
      @client.get_request("/send/list")
    end

    def get(id)
      @client.get_request("/send/get/id/#{id}")
    end

    # allows you to cancel a pending send
    def cancel(id)
      @client.get_request("/send/cancel/id/#{id}")
    end

    def track(id)
      @client.get_request("/send/track/id/#{id}")
    end
  end
end
