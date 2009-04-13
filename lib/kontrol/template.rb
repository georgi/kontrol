module Kontrol

  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template
    include Helpers

    # Initialize this template with an ERB instance.
    def initialize(app, vars)
      @__app__ = app
      
      vars.each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end

    def __binding__
      binding
    end

    def self.render(erb, app, file, vars)
      template = Template.new(app, vars)
      
      return erb.result(template.__binding__)

    rescue => e
      e.backtrace.each do |s|
        s.gsub!('(erb)', file)
      end
      raise e
    end

    def method_missing(id, *args, &block)
      if @__app__.respond_to?(id)
        return @__app__.send(id, *args, &block)
      end
      super
    end

  end

end
