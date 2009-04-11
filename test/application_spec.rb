require 'kontrol'
require 'git_store'
require 'rack/mock'

describe Kontrol::Builder do

  REPO = File.exist?('/tmp') ? '/tmp/test' : File.expand_path(File.dirname(__FILE__) + '/repo')

  before do
    FileUtils.rm_rf REPO
    Dir.mkdir REPO
    Dir.chdir REPO
    `git init`

    ENV['RACK_ENV'] = 'production'

    @class = Class.new(Kontrol::Application)
    @app = @class.new(REPO)
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
    @class.map(&block)
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

  it "should redirect" do
    map do
      get '/' do redirect 'x' end
    end

    get('/')['Location'].should == 'x'
    get('/').status.should == 301
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
    file 'assets/javascripts/index.js', 'index'
    file 'assets/stylesheets/styles.css', 'styles'
    file 'assets/file', 'file'
    
    map do
      get '/assets/javascripts\.js' do
        scripts = store['assets/javascripts'].to_a.join
        if_none_match(etag(scripts)) { scripts }
      end

      get '/assets/stylesheets\.css' do
        styles = store['assets/stylesheets'].to_a.join
        if_none_match(etag(styles)) { styles }
      end

      get '/assets/(.*)' do |path|
        file = store['assets'][path]
        if_none_match(etag(file)) { file }
      end
    end

    get("/assets/javascripts.js").body.should == 'index'
    get("/assets/javascripts.js")['Content-Type'].should == 'text/javascript'
    get("/assets/stylesheets.css").body.should == 'styles'
    get("/assets/stylesheets.css")['Content-Type'].should == 'text/css'
    
    get("/assets/file").body.should == 'file'
    etag = get("/assets/file")['Etag']
    
    get("/assets/file", 'HTTP_IF_NONE_MATCH' => etag).status.should == 304
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
