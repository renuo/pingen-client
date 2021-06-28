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

    def upload(pdf)
      post_multipart_request("/document/upload", pdf, {})
    end

    def pdf(id)
      get_request("/document/pdf/id/#{id}")
    end

    def delete(id)
      post_request("/document/delete/id/#{id}", {})
    end

    def schedule_send(id, fast_send: false, color: false)
      post_request("/document/send/id/#{id}", {color: color ? 1 : 0, speed: fast_send ? 1 : 2})
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
  end
end
