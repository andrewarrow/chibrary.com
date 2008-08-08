class ListController < ApplicationController
  before_filter :load_list, :load_list_snippets
  caches_page :show

  def show
    @title = "#{@list['name'] or @slug} archive"
    @year_counts = ThreadList.year_counts @slug
  end
end
