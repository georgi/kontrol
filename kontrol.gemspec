Gem::Specification.new do |s|
  s.name = 'kontrol'
  s.version = '0.1'
  s.date = '2008-12-17'
  s.summary = 'a micro framework'
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://github.com/georgi/kontrol'  
  s.description = "A small web framework running as rack application."
  s.files = %w{ .gitignore
                LICENSE
                README.md
                lib/kontrol.rb
                lib/kontrol/application.rb
                lib/kontrol/builder.rb
                lib/kontrol/helpers.rb
                lib/kontrol/router.rb
                lib/kontrol/template.rb
                test/application_spec.rb }
  s.require_path = 'lib'
  s.add_dependency 'git_store'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']  
end

