module Pingen
  class Documents
    def initialize(client = Client.new)
      @client = client
    end

    def list
      @client.get_request("/document/list")
    end

    def get(id)
      @client.get_request("/document/get/id/#{id}")
    end

    # fast_send: true | false, default: false.
    #   true - A Post
    #   false - B Post
    def upload(pdf, send: false, fast_send: false, color: false)
      data = {send: send}.merge(send ? parse_send_params(fast_send, color) : {})
      @client.post_multipart_request("/document/upload", pdf, data: data.to_json)
    end

    # fast_send: true | false, default: false.
    #   true - A Post
    #   false - B Post
    def send(id, fast_send: false, color: false)
      @client.post_request("/document/send/id/#{id}", parse_send_params(fast_send, color))
    end

    def pdf(id)
      @client.get_request("/document/pdf/id/#{id}")
    end

    def delete(id)
      @client.post_request("/document/delete/id/#{id}", {})
    end

    private

    def parse_send_params(fast_send, color)
      {color: color ? 1 : 0, speed: fast_send ? 1 : 2}
    end
  end
end
