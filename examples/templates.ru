require 'kontrol'

class Templates < Kontrol::Application
  map do
    get '/(.*)' do |name|
      render "page.rhtml", :title => name.capitalize, :body => "This is the body!"
    end
  end
end

run Templates.new
