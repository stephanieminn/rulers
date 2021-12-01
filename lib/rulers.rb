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
        [200, {'Content-Type' => 'text/html'},
          [text]]
      rescue => exception
        STDERR.puts exception.inspect
        [500, {'Content-Type' => 'text/html'},
          ["Uh oh! Error: #{exception.message}"]]
      end
    end
  end
end
