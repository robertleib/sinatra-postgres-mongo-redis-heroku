require_relative 'account'
require_relative 'user'

module Eat
  @queue = :critical

  def self.perform(food)
    puts "Ate #{food}!"
  end
end