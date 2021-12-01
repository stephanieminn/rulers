require "erubis"

module Rulers
  class Controller
    def initialize(env)
      @env = env
      @controller_name = Rulers::Application.new.get_controller_and_action(env).first
      @user_agent = env["HTTP_USER_AGENT"]
      @rulers_version = Rulers::VERSION
    end

    attr_reader :env, :controller_name, :user_agent, :rulers_version

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
  end
end
