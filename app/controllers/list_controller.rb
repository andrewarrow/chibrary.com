class ListController < ApplicationController
  before_filter :load_list
  caches_page :show

  def show
    @title = "#{@list['name'] or @slug} archive"
    @year_counts = @list.year_counts

    @snippets = []
    begin
      $archive["snippet/list/#{@slug}"].each_with_index { |key, i| @snippets << $archive["snippet/list/#{@slug}/#{key}"] ; break if i >= 30 }
    rescue NotFound ; end
  end
end