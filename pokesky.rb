require 'json'
require './tests'
require './entityloader'
require './console'

module PokeSky
  extend PokeSky

  @el = EntityLoader.instance

  # What are we going to do?
  def main

    # test

    # Console.new
    console_start
  end

end

PokeSky.main
