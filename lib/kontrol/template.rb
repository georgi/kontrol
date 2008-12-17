module Kontrol

  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template
    include Helpers

    # Initialize this template with an ERB instance.
    def initialize(app)
      @__app__ = app
    end

    def __binding__
      binding
    end

    def self.render(erb, app, file, vars)
      template = Template.new(app)

      for name, value in vars
        template.send :instance_variable_set, "@#{name}", value
      end

      result = erb.result(template.__binding__)

      for name in template.instance_variables
        vars[name[1..-1]] = template.send(:instance_variable_get, name) unless name == '@__app__'
      end

      return result

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
