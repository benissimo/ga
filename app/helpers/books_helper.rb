module BooksHelper
  
  def fmt_euro(amt)
    sprintf("&euro; %0.2f",amt)
  end

  def highlight_keyword(keyword, string)
    unless keyword
      string
    else
      reg = Regexp.new(Regexp.escape(keyword), 'i')
      string.gsub(reg,'<span class="hl">\0</span>')
    end
  end
end
