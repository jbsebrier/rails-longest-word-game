require 'open-uri'
require 'json'


class GameController < ApplicationController

def game
@grid = generate_grid(9)


end

def generate_grid(grid_size)
  grid = []
  grid_size.times do |letter|
    letter = [*("A".."Z")].sample
    grid << letter
  end
  return grid
  #
end



def score
@grid2 = params[:grid].split(//)
@attempt = params[:attempt]
@score_hash = run_game(@attempt, @grid2)
end

def unexistant_word_hash(attempt, grid)
  { score: 0,
    message: "not an english word",
    translation: nil }
end

def non_compliant_word_hash(attempt, grid)
  { score: 0,
    message: "not in the grid",
    translation: nil }
end

def ok_word_hash(attempt, grid)
  { score: attempt.length,
    message: "well done",
    translation: word_trans_checking(attempt) }
end

def run_game(attempt, grid)
  result_hash = {}

  if word_trans_checking(attempt) == "Error"
    result_hash = unexistant_word_hash(attempt, grid)
  elsif word_grid_checking(attempt, grid) > 0
    result_hash = non_compliant_word_hash(attempt, grid)
  else
    result_hash = ok_word_hash(attempt, grid)
  end
  return result_hash
end

def url_generator(attempt)
  "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
end


def word_trans_checking(attempt)
  api_url = url_generator(attempt)
  open(api_url) do |stream|
    translated_word = JSON.parse(stream.read)
    if translated_word["Error"].nil?
      answer = translated_word ["term0"]["PrincipalTranslations"]["0"]['FirstTranslation']['term']
    else answer = "Error"
    end
    return answer
  end
end

def letter_count(array)
  letters_hash = {}
  array.each do |letter|
    if letters_hash[letter]
      letters_hash[letter] += 1
    else
      letters_hash[letter] = 1
    end
  end
  return letters_hash
end


def word_grid_checking(attempt, grid)
  attempt_letters = attempt.upcase.split("")
  error_count = 0
  attempt_letters.each do |letter|
    if letter_count(grid)[letter].nil?
      error_count += 1
    elsif letter_count(attempt_letters)[letter] > letter_count(grid)[letter]
      error_count += 1
    end
  end
  return error_count
end



end
