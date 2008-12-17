module Kontrol

  class Router

    def initialize
      @routing = []      
    end

    def map(pattern, block, options = {})
      @routing << [pattern, block, options]
    end

    OPTION_MAPPING = {
      :method => 'REQUEST_METHOD',
      :port => 'SERVER_PORT',
      :host => 'HTTP_HOST',
      :accept => 'HTTP_ACCEPT',
      :query => 'QUERY_STRING',
      :content_type => 'CONTENT_TYPE'      
    }

    def options_match(env, options)      
      options.all? do |name, pattern| 
        value = env[OPTION_MAPPING[name] || name]
        value and pattern.match(value)
      end
    end

    def call(env)
      path = env["PATH_INFO"].to_s.squeeze("/")      

      for pattern, app, options in @routing
        match = path.match(/^#{pattern}/)
        if match and options_match(env, options)
          env = env.dup
          (env['kontrol.args'] ||= []).concat(match.to_a[1..-1])
          if match[0] == pattern
            env["SCRIPT_NAME"] += match[0]
            env["PATH_INFO"] = path[match[0].size..-1]
          end
          return app.call(env)
        end
      end

      [404, {"Content-Type" => "text/plain"}, ["Not Found: #{env['REQUEST_URI']}"]]
    end

  end

end
