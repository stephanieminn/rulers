require "erubis"

module Rulers
  class Controller
    def initialize(env)
      @env = env
      @routing_params = {}
      @user_agent = env["HTTP_USER_AGENT"]
      @rulers_version = Rulers::VERSION
    end

    attr_reader :env, :controller_name, :user_agent, :rulers_version

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      text = self.send(action)
      r = get_response
      if r
        [r.status, r.headers, [r.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(act, rp = {})
      proc { |e| self.new(e).dispatch(act, rp) }
    end

    def render(view_name, locals = {})
      filename = File.join "app", "views", controller_name, "#{view_name}.html.erb"
      template = File.read filename
      eruby = Erubis::Eruby.new(template)
      ivars = self.instance_variables.reduce({}) do |acc, var|
        acc[var] = self.instance_variable_get var.to_sym
        acc
      end

      eruby.result locals.merge(ivars)
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub /Controller$/, ""
      Rulers.to_underscore klass
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def params
      request.params.merge @routing_params
    end

    def response(text, status = 200, headers = {})
      raise "Already responded!" if @response
      a = [text].flatten
      @response = Rack::Response.new(a, status, headers)
    end

    def get_response  # Only for Rulers
      @response
    end

    def render_response(*args)
      response(render(*args))
    end
  end
end
