require 'kontrol'
require 'bluecloth'

class GitApp < Kontrol::Application

  def initialize(path)
    super
    @store = GitStore.new(path)
  end
  
  map do
    page '/(.*)' do |name|
      text BlueCloth.new(@store[name + '.md']).to_html
    end
  end
end

run GitApp.new
