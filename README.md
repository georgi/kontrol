Kontrol - a micro framework
===========================

Kontrol is a small web framework written in Ruby, which runs directly
on [Rack][5]. It provides a simple pattern matching algorithm for routing
and uses GitStore as data storage.

All examples can be found in the [examples folder][3] of the kontrol
project, which is hosted on [this github page][4].

## Quick Start

Create a file named `hello_world.ru`:

    require 'kontrol'
    
    class HelloWorld < Kontrol::Application
      map do
        get '/' do
          "Hello World!" 
        end
      end
    end
        
    run HelloWorld.new
    
Now run:

    rackup hello_world.ru

Browse to `http://localhost:9292` and you will see "Hello World".


## Features

Kontrol is just a thin layer on top of Rack. It provides a routing
algorithm, a simple template mechanism and some convenience stuff to
work with [GitStore][1].

A Kontrol application is a class, which provides some context to the
defined actions. You will probably use these methods:

  * request: the Rack request object
  * response: the Rack response object
  * params: union of GET and POST parameters
  * cookies: shortcut to request.cookies
  * session: shortcut to `request.env['rack.session']`
  * redirect(path): renders a redirect response to specified path


## Routing

Routing is just as simple as using regular expressions with
groups. Each group will be provided as argument to the block.

Create a file named `routing.ru`:

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
    
Now run this application:

    rackup routing.ru


You will now see, how regex groups and parameters are related. For
example if you browse to `localhost:9292/2008/12`, the app will
display `Archive for 2008/12`.


## Nested Routes

Routes can be nested. This way you can avoid repeating patterns and
define handlers for a set of HTTP verbs. Each handler will be called
with the same arguments.

    require 'kontrol'
    
    class Nested < Kontrol::Application
      map do
        map '/blog' do
          get '/archives' do
            "The archives!"
          end
        end
        
        map '/(.*)' do
          get do |path|
            "<form method='post'><input type='submit'/></form>"
          end
          
          post do |path|
            "You posted to #{path}"
          end
        end
      end
    end
    
    run Nested.new

Now run this app like:

    rackup nested.ru
    
The second route catches all paths except the `/blog` route. Inside
the second route there are two different handlers for `GET` and `POST`
actions.

So if you browse to `/something`, you will see a submit button. After
submitting you will see the result of the second handler.

## Templates

Rendering templates is as simple as calling a template file with some
parameters, which are accessible inside the template as instance
variables. Additionally you will need a layout template.

Create a template named `templates/layout.rhtml`:

    <html>
      <body>
        <%= @content %>
      </body>
    </html>

And now another template named `templates/page.rhtml`:

    <h1><%= @title %></h1>
    <%= @body %>

Create a templates.ru file:

    require 'kontrol'
    
    class Templates < Kontrol::Application
      map do
        get '/(.*)' do |name|
          render "page.rhtml", :title => name.capitalize, :body => "This is the body!"
        end
      end
    end
    
    run Templates.new

Now run this example:

    rackup templates.ru

If you browse to any path on `localhost:9292`, you will see the
rendered template. Note that the title and body parameters have been
passed to the `render` call.


## Using GitStore

[GitStore][1] is another library, which allows you to store code and
data in a convenient way in a git repository. The repository is
checked out into memory and any data may be saved back into the
repository.

Install [GitStore][1] and [Grit][2] by:

    $ gem sources -a http://gems.github.com (you only have to do this once)
    $ sudo gem install mojombo-grit georgi-git_store

We create a Markdown file name `pages/index.md`:

    Hello World
    ===========

    This is the **Index** page!

We have now a simple page, which should be rendered as response. We
create a simple app in a file `git_app.ru`:

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

Add all these files to your repo:

    git init
    git add pages/index.md
    git add git_app.ru
    git commit -m 'init'

Run the app:

    rackup git_app.ru

Browse to `http://localhost:9292/index` and you will see the rendered
page generated from the markdown file.

This application runs straight from the git repository. You can delete
all files except the rackup file and the app will still serve the page
from your repo.


[1]: http://github.com/georgi/git_store
[2]: http://github.com/mojombo/grit
[3]: http://github.com/georgi/kontrol/tree/master/examples
[4]: http://github.com/georgi/kontrol
[5]: http://github.com/chneukirchen/rack
[6]: http://github.com/chneukirchen/rack/tree/master/lib/rack/request.rb
[7]: http://github.com/chneukirchen/rack/tree/master/lib/rack/response.rb
