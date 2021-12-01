require "rulers/file_model"

module Rulers
  module Model
    class Cache
      def initialize
        @hash = {}

        # Initializing the cache upfront
        files = Dir["db/quotes/*.json"]
        models = files.map { |f| FileModel.new f }
        models.each do |model|
          @hash[model.id] = model
        end

        STDERR.puts "Existing records cached!"
      end

      def fetch_all
        STDERR.puts "You hit the cache!"
        @hash.values
      end

      def [](id)
        STDERR.puts "You hit the cache!"
        @hash[id]
      end

      def []=(id, object)
        STDERR.puts "Caching #{object.inspect}!"
        @hash[id] = object
      end
    end
  end
end
