require_relative 'game'
require_relative 'user_interface_helper'

module Codebreaker
  class UserInterface
    include UIHelper

    def main_menu
      greeting_message
      user_input == 'exit' ? bye : play
    end

    def play
      create_new_game
      start_game_message
      playing
      lost unless attempts?
      score
      after_game_menu
    end

    private

    def create_new_game
      @game = Game.new
    end

    def playing
      while attempts?
        used_attempts_message
        input = user_input
        if call_hint?(input)
          show_hint
        else
          result = @game.make_guess(input)
          result ? puts(result) : incorrect_format_message
        end
        if won?(result)
          won
          break
        end
      end
    end

    def attempts?
      @game.used_attempts < Game::ATTEMPTS
    end

    def call_hint?(input)
      input.match(/^h$/)
    end

    def show_hint
      @game.used_hints < Game::HINTS ? puts(@game.hint) : no_hints_message
    end

    def show_result(result)
      puts result
    end

    def won?(result)
      result == '++++'
    end

    def won
      @game_status = 'won'
      won_message
    end

    def lost
      @game_status = 'lost'
      lost_message
    end

    def score
      puts "Attempts used: #{@game.used_attempts}"
      puts "Hints used: #{@game.used_hints}"
    end

    def after_game_menu
      after_game_message
      choise = user_input[/^[yns]/]

      send(
        {
          y: 'play',
          n: 'bye',
          s: 'save'
        }[choise.to_sym]
      )
      main_menu
    end

    def save
      name = ask_name
      @game.save_result(username: name, game_status: @game_status)
      saved_result_message
    end

    def user_input
      gets.chomp
    end

    def ask_name
      puts 'Please, type your name:'
      gets.chomp
    end

    def bye
      puts 'Bye!'
      exit
    end
  end
end
