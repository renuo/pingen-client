require "net/http"
require "net/http/post/multipart"
require_relative "response"

module Pingen
  class Client
    DEFAULT_TIMEOUT = 60 # in seconds

    class NoLogger
      def call(_url, _request)
        yield
      end
    end

    def initialize(base_url: nil, token: nil, logger: NoLogger.new)
      @base_url = base_url || ENV["PINGEN_API_URL"] || "https://api.pingen.com"
      @token = token || ENV["PINGEN_API_TOKEN"]
      @logger = logger
    end

    def list
      get_request("/document/list")
    end

    def get(id)
      get_request("/document/get/id/#{id}")
    end

    # send_params:
    # fast_send: true | false, default: false.
    #   true - A Post
    #   false - B Post
    # color: true | false, default: false
    def upload(pdf, send: false, **send_params)
      data = {send: send}.merge(send ? parse_send_params(send_params) : {})
      post_multipart_request("/document/upload", pdf, data: data.to_json)
    end

    def pdf(id)
      get_request("/document/pdf/id/#{id}")
    end

    def delete(id)
      post_request("/document/delete/id/#{id}", {})
    end

    # send_params:
    # fast_send: true | false, default: false.
    #   true - A Post
    #   false - B Post
    # color: true | false, default: false
    def schedule_send(id, **send_params)
      post_request("/document/send/id/#{id}", parse_send_params(send_params))
    end

    # allows you to cancel a pending send
    def cancel_send(send_id)
      get_request("/send/cancel/id/#{send_id}")
    end

    def track(send_id)
      get_request("/send/track/id/#{send_id}")
    end

    def get_request(path, params = nil, request_params = {})
      url = build_url(path)
      req = build_get_request(url, params)
      perform_request(url, req, request_params)
    end

    def post_request(path, params, request_params = {})
      url = build_url(path)
      request = build_post_request(url, params)
      perform_request(url, request, request_params)
    end

    def post_multipart_request(path, file, params, request_params = {})
      url = build_url(path)
      request = build_multipart_post_request(url, file, params)
      perform_request(url, request, request_params)
    end

    protected

    def build_url(path)
      uri = @base_url.dup
      uri << "/" unless uri.end_with? "/"
      path << "/token/#{@token}"
      URI.join(URI.parse(uri), path)
    end

    def build_get_request(url, params)
      url.query = URI.encode_www_form(params) unless params.nil?
      Net::HTTP::Get.new(url).tap(&method(:header_params))
    end

    def build_multipart_post_request(url, file_path, params)
      Net::HTTP::Post::Multipart.new(url.path,
        params.merge("file" => UploadIO.new(file_path,
          "application/pdf",
          File.basename(file_path))))
    end

    def build_post_request(url, params)
      Net::HTTP::Post.new(url.path).tap do |request|
        header_params(request)
        request.body = params.to_json
      end
    end

    def perform_request(url, request, request_params)
      http_new = Net::HTTP.new(url.hostname, url.port)
      manipulate_http_request(http_new, request_params)
      Response.from(@logger.call(url, request) { http_new.start { |http| http.request(request) } })
    end

    def manipulate_http_request(http_new, request_params)
      http_new.use_ssl = @base_url.start_with?("https")
      http_new.open_timeout = DEFAULT_TIMEOUT
      http_new.read_timeout = DEFAULT_TIMEOUT
      request_params.each do |key, val|
        http_new.public_send("#{key}=", val)
      end
    end

    def header_params(request)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
    end

    private

    def parse_send_params(**params)
      {color: params[:color] ? 1 : 0, speed: params[:fast_send] ? 1 : 2}
    end
  end
end
