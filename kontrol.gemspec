Gem::Specification.new do |s|
  s.name = 'kontrol'
  s.version = '0.4'
  s.summary = 'a micro framework'
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://github.com/georgi/kontrol'  
  s.description = "Small web framework running on top of rack."
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']  
  s.files = %w{
LICENSE
README.md
examples/git_app.ru
examples/hello_world.ru
examples/routing.ru
examples/templates.ru
examples/templates/layout.rhtml
examples/templates/page.rhtml
lib/kontrol.rb
lib/kontrol/application.rb
lib/kontrol/helpers.rb
lib/kontrol/mime_types.rb
lib/kontrol/route.rb
lib/kontrol/router.rb
lib/kontrol/template.rb
test/application_spec.rb
test/route_spec.rb
test/router_spec.rb
}
end

