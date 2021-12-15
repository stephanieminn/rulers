require "rulers/cache"

module Rulers
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename
        # If filename is "dir/37.json", @id is 37
        basename = File.split(filename)[-1]
        @id = File.basename(basename, ".json").to_i
        obj = File.read(filename)
        @hash = MultiJson.load(obj)
      end

      attr_reader :id, :hash

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save
        json = MultiJson.dump(@hash)
        File.open("db/quotes/#{@id}.json", "w") do |f|
          f.write json
        end

        self
      end

      def self.method_missing(method_name, *args)
        if method_name.to_s.start_with?("find_all_by_")
          attribute = method_name.to_s.split("_").last
          return send(:find_all_by, attribute, args[0])
        end

        super
      end

      def self.respond_to_missing?(method_name, include_private = false)
        method_name.to_s.start_with?("find_all_by_") || super
      end

      def self.find(id)
        begin
          @@cache[id]
        rescue
          return nil
        end
      end

      def self.find_all_by(attribute, value)
        begin
          models = all
          models.select { |m| m.hash[attribute] == value }
        rescue
          return []
        end
      end

      def self.all
        @@cache.fetch_all
      end

      def self.create(attrs)
        data = {}
        data["submitter"] = attrs["submitter"] || ""
        data["quote"] = attrs["quote"] || ""
        data["attribution"] = attrs["attribution"] || ""
        files = Dir["db/quotes/*.json"]
        names = files.map { |f| File.split(f)[-1] }
        highest = names.map { |b| b.to_i }.max
        id = highest + 1

        File.open("db/quotes/#{id}.json", "w") do |f|
          f.write <<-TEMPLATE
          {
            "submitter": "#{data["submitter"]}",
            "quote": "#{data["quote"]}",
            "attribution": "#{data["attribution"]}"
          }
          TEMPLATE
        end

        model = FileModel.new "db/quotes/#{id}.json"
        @@cache[id] = model
        model
      end


      @@cache = Cache.new
    end
  end
end
