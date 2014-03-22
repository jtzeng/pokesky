require 'singleton'

module PokeSky

  class EntityLoader
    include Singleton

    PATH = './data.json'

    attr_accessor :expr

    def self.instance
      @@instance ||= new
    end

    # Load data from a JSON file.
    def initialize
      @expr = nil
      File.open(PATH) do |f|
        data = f.readlines.map { |s| s.strip }.join
        @expr = JSON.parse(data)
      end

      if not @expr
        raise "The file at '#{PATH}' was unable to be parsed."
        return
      end
    end

  end

end
