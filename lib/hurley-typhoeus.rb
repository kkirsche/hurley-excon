require "typhoeus"

module HurleyTyphoeus
  VERSION = '0.0.1'
  DEFAULT_CHUNK_SIZE = 1048576

  class Connection
    def initialize(options = nil)
      @options = options || {}
    end

    def call(request)
      opts = {}
      configure_ssl(opts, request.ssl_options) if request.url.scheme == Hurley::HTTPS
      configure_request(opts, request.options)
      configure_proxy(opts, request.options)

      Hurley::Response.new(request) do |res|
        typhoeus = perform(res, opts)
        res.status_code = typhoeus.code.to_i
        res.header.update(typhoeus.headers)
        body = typhoeus.body.to_s
        res.receive_body(body) if !body.empty?
      end
    end

    def perform(res, options)
      req = res.request

      req_options = {
        :method  => req.verb,
        :headers => req.header
      }

      puts req.verb

      request = Typhoeus::Request.new(req.url.to_s, req_options)

      if body = req.body_io
        request.on_body do |chunk|
          body.read(HurleyTyphoeus::DEFAULT_CHUNK_SIZE)
        end
      end

      request.run
    rescue ::Typhoeus::Errors::TyphoeusError => err
      if err.message =~ /\btimeout\b/
        raise Hurley::Timeout, err
      elsif err.message =~ /\bcertificate\b/
        raise Hurley::SSLError, err
      else
        raise Hurley::ConnectionFailed, err
      end
    end

    def configure_ssl(opts, ssl)
      opts[:ssl_verify_peer] = !ssl.skip_verification?
      opts[:ssl_ca_path] = ssl.ca_path if ssl.ca_path
      opts[:ssl_ca_file] = ssl.ca_file if ssl.ca_file

      opts[:certificate_path] = ssl.client_cert_path if ssl.client_cert_path
      opts[:certificate] = ssl.client_cert if ssl.client_cert

      opts[:private_key] = ssl.private_key if ssl.private_key
      opts[:private_key_path] = ssl.private_key_path if ssl.private_key_path
      opts[:private_key_pass] = ssl.private_key_pass if ssl.private_key_pass

      # https://github.com/geemus/typhoeus/issues/106
      # https://github.com/jruby/jruby-ossl/issues/19
      opts[:nonblock] = false
    end

    def configure_request(opts, options)
      if t = options.timeout
        opts[:read_timeout] = t
        opts[:connect_timeout] = t
        opts[:write_timeout] = t
      end

      if t = options.open_timeout
        opts[:connect_timeout] = t
        opts[:write_timeout] = t
      end
    end

    def configure_proxy(opts, options)
      return unless proxy = options.proxy
      opts[:proxy] = {
        :host => proxy.host,
        :port => proxy.port,
        :scheme => proxy.scheme,
        :user => proxy.user,
        :password => proxy.password,
      }
    end
  end
end
