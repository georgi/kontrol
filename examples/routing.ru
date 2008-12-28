require 'kontrol'

class Routing < Kontrol::Application
  map do
    get '/pages/(.*)' do |name|
      "This is the page #{name}!"
    end

    get '/(\d*)/(\d*)' do |year, month|
      "Archive for #{year}/#{month}"
    end
  end
end

run Routing.new
