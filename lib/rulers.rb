# frozen_string_literal: true

require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"
require "rulers/cache"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404,
          {'Content-Type' => 'text/html'}, []]
      end

      klass, act = get_controller_and_action(env)
      controller = klass.new(env)
      begin
        text = controller.send(act)
        r = controller.get_response
        if r
          [r.status, r.headers, [r.body].flatten]
        else
          controller.render_response act.to_sym
        end
      rescue => exception
        STDERR.puts exception.backtrace
        [500, {'Content-Type' => 'text/html'},
          ["Uh oh! Error: #{exception.message}"]]
      end
    end
  end
end
