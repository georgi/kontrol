Kontrol - a micro framework
===========================

Kontrol is a small web framework written in Ruby, which runs directly
on Rack. It provides a simple pattern matching algorithm for routing
and uses GitStore as data storage.

## Quick Start

Create a config.ru file and try this little "Hello World" app:

    require 'kontrol'

    run Kontrol::Application.new do
      get '/' do
        "Hello World!" 
      end
    end

Now run `rackup` and browse to `http://localhost:9292` you will see the "Hello World".


## Routing

Routing is just as simple as using regular expressions with
groups. Each group will be provided as argument to the block.

Some examples:

    require 'kontrol'

    run Kontrol::Application.new do
      get '/pages/(.*)' do |name|
        "This is the page #{name}!"
      end

      get '/(\d*)/(\d*)', :content_type => 'text/html' do |year, month|
        "Archive for #{year} #{month}"
      end
    end

The second route has the requirement, that the `content-type` header
should be 'text/html'.


## Nested Routes

You may nest your routes like you want:

    require 'kontrol'

    run Kontrol::Application.new do
      map '/blog' do
        get '/archives' do
          "The archives!"
        end
      end
    end

This app can be reached at '/blog/archives'.


## Storing your data in a git repository

Using GitStore for your code and data is a convenient way for
developing small scale apps. The whole repository is loaded into the
memory and any change in the repository is reflected immediately in
you in-memory copy.

Just init a new repo: `git init`

Now we create a template named `templates/layout.rhtml`:

    <html>
      <body>
        <%= @content %>
      </body>
    </html>

And now another template named `templates/page.rhtml`:

    <h1><%= @title %></h1>
    <%= @body %>

Now we create a Markdown file name `pages/index.md`:

    Hello World from **Markdown** !


Create a config.ru file:

    require 'kontrol'

    run Kontrol::Application.new do
      get '/(.*)' do |name|
        body = store["pages/#{name}.md"]
        render "page.rhtml", :title => name.capitalize, :body => body
      end
    end

Add all these files to your repo:

    git add templates/layout.rhtml
    git add templates/page.rhtml
    git add pages/index.md
    git add config.ru
    git commit -m 'added templates and config.ru'

Now just run `rackup` and browse to `http://localhost:9292/index`

You will see the rendered template with the inserted content of the
Markdown file.

