require 'kontrol'
require 'bluecloth'

class GitApp < Kontrol::Application

  def initialize(path)
    super
    @store = GitStore.new(path)
  end

  map do
    get '/(.*)' do |name|
      BlueCloth.new(@store['pages', name + '.md']).to_html
    end
  end
end

run GitApp.new
