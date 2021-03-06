require 'net/imap' # yes really

class String
  def decoded
    self.gsub(/=\?[^\?]+\?[^\?]+\?[^\?]+\?=/) do |encoded|
      charset, encoding, text = *encoded.match(/=\?([^\?]+)\?([^\?]+)\?([^\?]+)\?=/).captures
      if encoding == 'B'
        # base64
        text = text.unpack('m').first
      elsif encoding == 'Q'
        # quoted-printable, MIME encoding
        text = text.unpack('M').first
      end
      text.to_utf8 charset
    end
  end

  def to_utf8 charset
    case charset.downcase
    when 'ks_c_5601-1987'
      charset = 'CP949'
    when 'unknown-8bit'
      charset = 'ascii-8bit'
    when 'UTF-7'
      return Net::IMAP.decode_utf7(self)
    when 'utf8'
      charset = 'UTF-8'
    when 'x-mac-thai'
      charset = 'macthai'
    when 'x-unknown' # seriously?
      charset = 'ISO-8859-1'
    when 'x-user-defined' # just one message by one jerk
      charset = 'ISO-8859-1'
    end
    self.encode("UTF-8", charset, invalid: :replace, undef: :replace).force_encoding('UTF-8')
  end
end
