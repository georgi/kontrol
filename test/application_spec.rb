require 'kontrol'
require 'rack/mock'

describe Kontrol::Builder do

  REPO = File.expand_path(File.dirname(__FILE__) + '/test_repo')

  before do
    FileUtils.rm_rf REPO
    Dir.mkdir REPO
    Dir.chdir REPO
    `git init`

    @app = Kontrol::Application.new
    @request = Rack::MockRequest.new(@app)
  end

  def get(*args)
    @request.get(*args)
  end

  def post(*args)
    @request.post(*args)
  end

  def delete(*args)
    @request.delete(*args)
  end

  def put(*args)
    @request.put(*args)
  end
  
  def map(&block)
    @app.map(&block)
  end
  
  def file(file, data)
    FileUtils.mkpath(File.dirname(file))
    open(file, 'w') { |io| io << data }
    `git add #{file}`
    `git commit -m 'spec'`
    File.unlink(file)    
  end

  it "should understand all verbs" do
    map do
      get '/one' do 'one' end
      post '/one' do 'two' end
      delete '/one' do 'three' end
      put '/two' do 'four' end
    end

    get("/one").body.should == 'one'
    post("/one").body.should == 'two'
    delete("/one").body.should == 'three'
    put("/two").body.should == 'four'
  end

  it "should reload after a commit" do
    file 'file', 'file'

    map do
      get '/(.*)' do |path|
        store[path]
      end
    end

    get("/file").body.should == 'file'

    file 'file', 'changed'

    get("/file").body.should == 'changed'
  end

  it "should serve assets" do
    file 'config/assets.yml', '{ javascript_files: [index], stylesheet_files: [styles] }'
    file 'assets/javascripts/index.js', 'index'
    file 'assets/stylesheets/styles.css', 'styles'
    file 'assets/file', 'file'
    
    map do
      get '/assets/javascripts\.js' do
        render_javascripts
      end

      get '/assets/stylesheets\.css' do
        render_stylesheets
      end

      get '/assets/(.*)' do |path|
        if_modified_since do
          assets[path]
        end
      end
    end

    get("/assets/javascripts.js").body.should == 'index'
    get("/assets/javascripts.js")['Content-Type'].should == 'text/javascript'
    get("/assets/stylesheets.css").body.should == 'styles'
    get("/assets/stylesheets.css")['Content-Type'].should == 'text/css'
    
    get("/assets/file").body.should == 'file'
    last_mod = get("/assets/file")['Last-Modified']
    
    get("/assets/file", 'HTTP_IF_MODIFIED_SINCE' => last_mod).status.should == 304
  end

  it "should render templates" do
    file 'templates/layout.rhtml', '<%= @content %>'
    file 'templates/index.rhtml', '<%= @body %>'
    
    map do
      get '/' do
        render 'index.rhtml', :body => 'BODY'
      end
    end

    get('/').body.should == 'BODY'     
  end
  
end
