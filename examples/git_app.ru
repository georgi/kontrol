require 'kontrol'
require 'bluecloth'

class GitApp < Kontrol::Application
  map do
    get '/(.*)' do |name|
      BlueCloth.new(store['pages', name + '.md']).to_html
    end
  end
end

run GitApp.new
