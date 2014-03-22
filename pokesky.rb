require 'json'
require './tests'
require './entityloader'

module PokeSky
  extend PokeSky

  @el = EntityLoader.instance

  # What are we going to do?
  def main
    test
  end

end

PokeSky.main
