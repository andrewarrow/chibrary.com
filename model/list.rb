class InvalidSlug < RuntimeError ; end

class NullList
  attr_reader :slug, :name, :description, :homepage

  def initialize
    @slug = '_null_list'
    @name = 'NillList'
  end
end

class List
  attr_reader :slug, :name, :description, :homepage

  def initialize slug, name=nil, description=nil, homepage=nil
    raise InvalidSlug, "Invalid list slug '#{slug}'" unless slug =~ /^[a-z0-9\-]+$/ and slug.length <= 20
    @slug = slug
    @name = name
    @description = description
    @homepage = homepage
  end

  # all the rest of this needs to move off into MesageList and Thread
  def cached_message_list year, month
    begin
      $riak[month_list_key(year, month)] or []
    rescue NotFound
      []
    end
  end

  def fresh_message_list year, month
    $riak.list "list/#{@slug}/message/#{year}/#{month}"
  end

  def cache_message_list year, month, message_list
    $riak[month_list_key(year, month)] = message_list
  end

  def thread year, month, call_number
    $riak["list/#{@slug}/thread/#{year}/#{month}/#{call_number}"]
  end

  def == other
    (
      slug == other.slug and
      name == other.name and
      description == other.description and
      homepage == other.homepage
    )
  end

  private

  def month_list_key year, month
    "list/#{@slug}/message_list/#{year}/#{month}"
  end
end