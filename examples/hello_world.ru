require 'kontrol'

class HelloWorld < Kontrol::Application
  map do
    get '/' do
      "Hello World!" 
    end
  end
end

run HelloWorld.new
