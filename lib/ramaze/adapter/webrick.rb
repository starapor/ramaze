require 'webrick'
require 'ramaze/tool/tidy'

module WEBrick
  class HTTPRequest
    def request_path
      request_uri.path
    end

    def remote_addr
      peeraddr.last
    end
  end
end

module Ramaze::Adapter
  class Webrick
    def self.start host, port
      # TODO
      # - add host
      # - implement graceful shutdown

      handler = lambda do |request, response|
        self.new.process(request, response)
      end

      server = WEBrick::HTTPServer.new(:Port => port, :BindAddress => host)
      server.mount('/', WEBrick::HTTPServlet::ProcHandler.new(handler))
      Thread.new{ server.start }
    end

    def process request, response
      respond(response, Dispatcher.handle(request, response))
    end

    def process_request(request)
      request.define_method(:request_path){ request_uri.path }
      request
    end

    def respond orig_response, response
      @response = orig_response
      if response
        set_head(response)
        set_out(response)
      end
      @response
    end

    def set_head(response)
      response.head.each do |key, val|
        @response[key] = val
      end
    end

    def set_out response
      @response.body = 
        if Global.tidy and (response.head['Content-Type'] == 'text/html' ? true : false)
          Tool::Tidy.tidy(response.out)
        else
          response.out
        end
    end
  end
end
