module Kontrol

  class Application

    include Helpers

    class << self

      def config_reader(file, *names)
        names.each do |name|
          name = name.to_s        
          define_method(name) { config[file][name] }
        end
      end
    end

    attr_reader :path, :store, :last_commit

    config_reader 'assets.yml', :javascript_files, :stylesheet_files

    def initialize(options = {}, &block)
      options.each do |k, v|
        send "#{k}=", v
      end

      @mtime = {}
      @last_mtime = Time.now
      @path = File.expand_path('.')
      
      @store = GitStore.new(path)
      @store.load
      
      map(&block) if block
    end

    def assets
      store['assets'] ||= GitStore::Tree.new
    end

    def config
      store['config'] ||= GitStore::Tree.new
    end

    def templates
      store['templates'] ||= GitStore::Tree.new
    end
    
    def repo
      @store.repo
    end

    def check_reload
      commit = store.repo.commits('master', 1)[0]

      if last_commit.nil? or last_commit.id != commit.id
        @last_commit = commit
        @last_mtime = last_commit.committed_date
        @mtime = {}
        store.load        
        load_store_from_disk
      elsif ENV['RACK_ENV'] != 'production'
        load_store_from_disk 
      end
    end

    def load_store_from_disk
      store.each_with_path do |blob, path|
        path = "#{self.path}/#{path}"
        if File.exist?(path)
          mtime = File.mtime(path)
          if mtime != @mtime[path]
            @mtime[path] = mtime
            @last_mtime = mtime if mtime > @last_mtime
            blob.load(File.read(path))
          end
        end
      end
    end

    def camelize(str)
      str.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end

    # Render template with given variables.
    def render_template(file, vars)
      templates[file] or raise "template #{file} not found"
      Template.render(templates[file], self, file, vars)
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

    def if_modified_since(date = @last_mtime.httpdate)
      response['Last-Modified'] = date
      if request.env['HTTP_IF_MODIFIED_SINCE'] == date
        response.status = 304
      else
        yield
      end
    end

    def render_javascripts
      if_modified_since do
        javascript_files.map { |file| assets["javascripts/#{file.strip}.js"] }.join
      end
    end

    def render_stylesheets
      if_modified_since do
        stylesheet_files.map { |file| assets["stylesheets/#{file.strip}.css"] }.join
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

    def map(&block)
      @map = Builder.new(&block)
    end

    def call(env)
      Thread.current['request'] = Rack::Request.new(env)
      Thread.current['response'] = Rack::Response.new([], nil, { 'Content-Type' => '' })

      check_reload
      
      env['kontrol.app'] = self

      map = @map || store['map.rb'] or raise "no map defined"

      status, header, body = map.call(env)

      response.status = status if response.status.nil?
      response.header.merge!(header)
      response.body = body if response.body.empty?
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

