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

    attr_reader :path, :store

    def initialize(path = '.')
      @path = File.expand_path(path)
      
      if File.directory?(File.join(path, '.git')) && ENV['RACK_ENV'] == 'production'
        @store = GitStore.new(path)
      else
        @store = GitStore::FileStore.new(path)
      end
    end

    def templates
      store['templates']
    end
    
    # Render template with given variables.
    def render_template(file, vars)
      template = templates[file] or raise "template #{file} not found"
      Template.render(template, self, file, vars)
    end

    def render_layout(vars)
      render_template(vars[:layout] || "layout.rhtml", vars)
    end

    # Render named template and insert into layout with given variables.
    def render(name, vars = {})
      content = render_template(name, vars)
      if name[0, 1] == '_' || name.match(/\.rxml$/)
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

      store.refresh!
      
      env['kontrol.app'] = self

      status, header, body = self.class.call(env)

      response.status = status if response.status.nil?
      response.header.merge!(header)
      response.body = body if response.body.empty?
      
      if response.status == 200
        response.body ||= ''
        response['Content-Length'] = response.body.size.to_s
      end
      
      response['Content-Type'] = guess_content_type if response['Content-Type'].empty?

      response.finish
    end

    def inspect
      "#<Kontrol::Application @path=#{path}>"
    end

    MIME_TYPES = {
      "ai"    => "application/postscript",
      "asc"   => "text/plain",
      "avi"   => "video/x-msvideo",
      "bin"   => "application/octet-stream",
      "bmp"   => "image/bmp",
      "class" => "application/octet-stream",
      "cer"   => "application/pkix-cert",
      "crl"   => "application/pkix-crl",
      "crt"   => "application/x-x509-ca-cert",
      "css"   => "text/css",
      "dms"   => "application/octet-stream",
      "doc"   => "application/msword",
      "dvi"   => "application/x-dvi",
      "eps"   => "application/postscript",
      "etx"   => "text/x-setext",
      "exe"   => "application/octet-stream",
      "gif"   => "image/gif",
      "htm"   => "text/html",
      "html"  => "text/html",
      "ico"   => "image/x-icon",
      "jpe"   => "image/jpeg",
      "jpeg"  => "image/jpeg",
      "jpg"   => "image/jpeg",
      "js"    => "text/javascript",
      "lha"   => "application/octet-stream",
      "lzh"   => "application/octet-stream",
      "mov"   => "video/quicktime",
      "mp3"   => "audio/mpeg",
      "mpe"   => "video/mpeg",
      "mpeg"  => "video/mpeg",
      "mpg"   => "video/mpeg",
      "pbm"   => "image/x-portable-bitmap",
      "pdf"   => "application/pdf",
      "pgm"   => "image/x-portable-graymap",
      "png"   => "image/png",
      "pnm"   => "image/x-portable-anymap",
      "ppm"   => "image/x-portable-pixmap",
      "ppt"   => "application/vnd.ms-powerpoint",
      "ps"    => "application/postscript",
      "qt"    => "video/quicktime",
      "ras"   => "image/x-cmu-raster",
      "rb"    => "text/plain",
      "rd"    => "text/plain",
      "rtf"   => "application/rtf",
      "rss"   => "application/rss+xml",
      "sgm"   => "text/sgml",
      "sgml"  => "text/sgml",
      "tif"   => "image/tiff",
      "tiff"  => "image/tiff",
      "txt"   => "text/plain",
      "xbm"   => "image/x-xbitmap",
      "xls"   => "application/vnd.ms-excel",
      "xml"   => "text/xml",
      "xpm"   => "image/x-xpixmap",
      "xwd"   => "image/x-xwindowdump",
      "zip"   => "application/zip",
    }
    
  end

end

