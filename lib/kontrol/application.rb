require 'digest/sha1'

module Kontrol

  class Application

    class << self
      def map(&block)
        if block
          @map = Builder.new(&block)
        else
          @map
        end
      end

      def call(env)
        @map.call(env)
      end     
    end
    
    include Helpers

    attr_reader :path

    def initialize(path = '.')
      @path = File.expand_path(path)      
    end

    def load_template(file)
      ERB.new(File.read("#{path}/templates/#{file}"))
    end
    
    # Render template with given variables.
    def render_template(file, vars)
      Template.render(load_template(file), self, file, vars)
    end

    def render_layout(vars)
      render_template(vars[:layout] || "layout.rhtml", vars)
    end

    # Render named template and insert into layout with given variables.
    def render(name, vars = {})
      content = render_template(name, vars)
      
      if name[0, 1] == '_' or vars[:layout] == false
        content
      else
        vars.merge!(:content => content)
        render_layout(vars)
      end
    end

    def etag(string)
      Digest::SHA1.hexdigest(string)
    end

    def if_modified_since(time)
      date = time.respond_to?(:httpdate) ? time.httpdate : time
      response['Last-Modified'] = date
      
      if request.env['HTTP_IF_MODIFIED_SINCE'] == date
        response.status = 304
      else
        yield        
      end
    end
    
    def if_none_match(etag)
      response['Etag'] = etag
      if request.env['HTTP_IF_NONE_MATCH'] == etag
        response.status = 304
      else
        yield
      end
    end
    
    def request
      Thread.current['request']
    end

    def response
      Thread.current['response']
    end

    def params
      request.params
    end

    def cookies
      request.cookies
    end

    def session
      request.env['rack.session']
    end

    def redirect(path)
      response['Location'] = path
      response.status = 301
      response.body = "Redirect to: #{path}"      
    end

    def guess_content_type
      ext = File.extname(request.path_info)[1..-1]
      MIME_TYPES[ext] || 'text/html'
    end

    def call(env)
      Thread.current['request'] = Rack::Request.new(env)
      Thread.current['response'] = Rack::Response.new([], nil, { 'Content-Type' => '' })

      env['kontrol.app'] = self

      status, header, body = self.class.call(env)

      response.status = status if response.status.nil?
      response.header.merge!(header)
      response.body = body if response.body.empty?
      
      if response.status != 304
        response.body ||= ''
        response['Content-Length'] = response.body.size.to_s
      end
      
      response['Content-Type'] = guess_content_type if response['Content-Type'].empty?

      response.finish
    end

    def inspect
      "#<#{self.class.name} @path=#{path}>"
    end
  end

end

