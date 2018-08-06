require "net/http"
require 'time'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @letters = ("A".."Z").to_a.sample(10)
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
    test_grid = @letters.split
    @time = Time.now - Time.parse(params[:start_time])
    valid_letters = @word.upcase.chars.all? { |char| test_grid.include?(char) ? test_grid.delete_at(test_grid.index(char)) : nil }
    dictionary_word = json_parse_from_url("https://wagon-dictionary.herokuapp.com/#{@word}")
    @result = check_dictionnary(@word, @time, dictionary_word, valid_letters, @letters)
    session[:cumulative_score] += @result[:score] || session[:cumulative_score] = 0
  end
end

def json_parse_from_url(url)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def check_dictionnary(attempt, time, word_hash, valid_letters, letters)
  result = Hash.new
  if word_hash["found"] && valid_letters == true
    result[:score] = ( (word_hash["length"].to_i * 100) / time ).round
    result[:message] = "Well done"
  else
    result[:score] = 0
    result[:message] = "#{attempt} is not an English word!" if valid_letters
    result[:message] = "#{attempt} cannot be built out of #{letters}" if !valid_letters
  end
  return result
end
