require_relative '../lib/core_ext/ice_nine_'

class Headers
  prepend IceNine::DeepFreeze

  attr_reader :text

  def initialize text
    @text = text || ''
  end

  def [] header
    match = /^#{header}:\s*(.*?)^\S/mi.match(text + "\n.")
    return '' if match.nil?
    # takes the first in case of duplicates
    match.captures.shift.sub(/(\s)+/, ' ').sub(/\n[ \t]+/m, " ").strip
  end
end