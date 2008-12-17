module Kontrol

  def self.map(&block)
    Builder.new(&block)
  end

  class Builder

    def initialize(&block)
      @router = Router.new
      @ins = []
      instance_eval(&block) if block
    end

    def use(middleware, *args, &block)
      @ins << lambda { |app| middleware.new(app, *args, &block) }
    end

    def run(app)
      @ins << app
    end

    def get(*args, &block)
      map_method(:get, *args, &block)
    end

    def put(*args, &block)
      map_method(:put, *args, &block)
    end

    def post(*args, &block)
      map_method(:post, *args, &block)
    end

    def delete(*args, &block)
      map_method(:delete, *args, &block)
    end

    def map(pattern, &block)
      @router.map(pattern, Builder.new(&block))
    end

    def call(env)
      to_app.call(env)
    end

    def to_app
      @ins.reverse.inject(@router) { |a, e| e.call(a) }
    end

    private

    def method_from_proc(obj, proc)
      name = "proc_#{proc.object_id}"
      unless obj.respond_to?(name)
        singleton = class << obj; self; end
        singleton.send(:define_method, name, &proc)
      end
      obj.method(name)
    end    

    def map_method(method, pattern = '.*', options = {}, &block)
      wrap = lambda do |env|
        env['kontrol.app'] or raise "no kontrol.app given"
        meth = method_from_proc(env['kontrol.app'], block)
        body = meth.call(*env['kontrol.args'])
        [200, {}, body]
      end
      @router.map(pattern, wrap, options.merge(:method => method.to_s.upcase))
    end

  end  

end
