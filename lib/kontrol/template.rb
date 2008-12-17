
module Shinmun

  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template
    attr_reader :erb, :blog

    # Initialize this template with an ERB instance.
    def initialize(erb, blog)
      @erb = erb
      @blog = blog
    end    

    # Set instance variable for this template.
    def set_variables(vars)
      for name, value in vars
        instance_variable_set("@#{name}", value)
      end
      self
    end

    # Render this template.
    def render
      @erb.result(binding)
    end

    # Render a hash as attributes for a HTML tag. 
    def attributes(attributes)
      attributes.map { |k, v| %Q{#{k}="#{v}"} }.join(' ')
    end

    # Render a HTML tag with given name. 
    # The last argument specifies the attributes of the tag.
    # The second argument may be the content of the tag.
    def tag(name, *args)
      text, attributes = args.first.is_a?(Hash) ? [nil, args.first] : args
      "<#{name} #{attributes(attributes)}>#{text}</#{name}>"
    end

    # Render stylesheet link tag
    def stylesheet_link_tag(*names)
      names.map { |name|
        mtime = File.mtime(File.join(blog.directory, "stylesheets/#{name}.css")).to_i
        path = "/stylesheets/#{name}.css?#{mtime}"
        tag :link, :href => path, :rel => 'stylesheet', :media => 'screen'
      }.join("\n")
    end

    # Render javascript tag
    def javascript_tag(*names)
      names.map { |name|
        mtime = File.mtime(File.join(blog.directory, "javascripts/#{name}.js")).to_i
        path = "/javascripts/#{name}.js?#{mtime}"
        tag :script, :src => path, :type => 'text/javascript'
      }.join("\n")
    end

    # Render an image tag
    def image_tag(src, options = {})
      tag :img, options.merge(:src => '/images/' + src)
    end

    # Render a link
    def link_to(text, path, options = {})
      tag :a, text, options.merge(:href => "/#{path}.html")
    end

    # Render a link for the navigation bar. If the text of the link
    # matches the @header variable, the css class will be set to acitve.
    def navi_link(text, path)
      link_to text, path, :class => (text == @header) ? 'active' : nil
    end

    # Render a link to a post
    def post_link(post)
      link_to post.title, post.path
    end

    # Render a link to an archive page.
    def month_link(year, month)
      link_to "#{Date::MONTHNAMES[month]} #{year}", "#{year}/#{month}/index"
    end

    # Render a date or time in a nice human readable format.
    def date(time)
      "%s %d, %d" % [Date::MONTHNAMES[time.month], time.day, time.year]
    end

    # Render a date or time in rfc822 format. This will be used for rss rendering.
    def rfc822(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %z")
    end

    def strip_tags(html)
      Shinmun.strip_tags(html)
    end

  end

end
