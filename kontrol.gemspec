Gem::Specification.new do |s|
  s.name = 'kontrol'
  s.version = '0.1.2'
  s.date = '2008-12-17'
  s.summary = 'a micro web framework'
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://github.com/georgi/kontrol'  
  s.description = "A small web framework running as rack application."
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']  
  s.files = %w{
.gitignore
LICENSE
README.md
lib/kontrol.rb
lib/kontrol/application.rb
lib/kontrol/builder.rb
lib/kontrol/helpers.rb
lib/kontrol/router.rb
lib/kontrol/template.rb
test/application_spec.rb
examples/routing.ru
examples/pages
examples/pages/index.md
examples/git_app.ru
examples/templates.ru
examples/templates
examples/templates/page.rhtml
examples/templates/layout.rhtml
examples/nested.ru
examples/hello_world.ru
}
end

