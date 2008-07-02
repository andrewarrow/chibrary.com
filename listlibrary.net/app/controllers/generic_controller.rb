class GenericController < ApplicationController
  def about
  end

  def homepage
    @lists = []
    $archive['list'].each do |slug|
      @lists << List.new(slug) if $archive.has_key? "list/#{slug}/thread"
    end
  end

  def search
  end
end