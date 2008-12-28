require 'kontrol'

class Nested < Kontrol::Application
  map do
    map '/blog' do
      get '/archives' do
        "The archives!"
      end
    end
    
    map '(.*)' do
      get do |path|
        "<form method='post'><input type='submit'/></form>"
      end
      
      post do |path|
        "You called #{path}"
      end
    end
  end
end

run Nested.new
