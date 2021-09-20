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

    # send_params:
    # fast_send: true | false, default: false.
    #   true - A Post
    #   false - B Post
    # color: true | false, default: false
    def upload(pdf, send: false, **send_params)
      data = {send: send}.merge(send ? parse_send_params(send_params) : {})
      @client.post_multipart_request("/document/upload", pdf, data: data.to_json)
    end

    # send_params:
    # fast_send: true | false, default: false.
    #   true - A Post
    #   false - B Post
    # color: true | false, default: false
    def send(id, **send_params)
      @client.post_request("/document/send/id/#{id}", parse_send_params(send_params))
    end

    def pdf(id)
      @client.get_request("/document/pdf/id/#{id}")
    end

    def delete(id)
      @client.post_request("/document/delete/id/#{id}", {})
    end

    private

    def parse_send_params(**params)
      {color: params[:color] ? 1 : 0, speed: params[:fast_send] ? 1 : 2}
    end
  end
end
