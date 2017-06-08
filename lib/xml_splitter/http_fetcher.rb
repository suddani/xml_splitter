class XmlSplitter::HttpFetcher
  DEFAULT_MAX_REDIRECTS = 5
  MAX_RETRIES = 5

  def config
    {}
  end

  def fetch_direct(url)
    @_uri = URI.parse(url)
    fetch_redirect(config['max_redirects'] || DEFAULT_MAX_REDIRECTS)
  end

  private

  def uri_obj
    @_uri
  end

  def fetch_redirect(redirects_remaining, cached=true)
    retries_remaining ||= config['max_retries'] || MAX_RETRIES
    raise "HTTP redirect too deep" if redirects_remaining == 0

    case response(cached)
      when Net::HTTPSuccess then response.body
      when Net::HTTPRedirection
        @_uri = URI.parse(response['location'])
        fetch_redirect(redirects_remaining - 1, false)
      else
        raise "IMPORT: Error when fetching XML: URL: #{uri_obj.to_s} CODE: #{response.code}; Message (#{response.msg}); Response (#{response.body}"
    end
  rescue StandardError => e
    retries_remaining -= 1
    sleep(1) and retry if retries_remaining >= 0
    raise e
  end

  def response(cached=true)
    return @response if cached && @response

    http = Net::HTTP.new(uri_obj.host, uri_obj.port)
    http.use_ssl = true if uri_obj.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if uri_obj.scheme == "https"
    http.read_timeout = config['timeout'] || 60

    @response = http.start do |transfer|
      transfer.request(request)
    end
  end

  def request
    request = config['fake_user_agent'] ? Net::HTTP::Get.new(uri_obj.request_uri, 'User-Agent' => config['fake_user_agent']) : Net::HTTP::Get.new(uri_obj.request_uri)
    if uri_obj.user && uri_obj.password
      request.basic_auth(uri_obj.user, uri_obj.password)
    end
    request
  end
end
