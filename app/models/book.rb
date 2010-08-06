class Book < ActiveRecord::Base

  belongs_to :category
  before_save :discard_empty_isbn
  validates_presence_of :title, :author, :price, :category_id
  validates_length_of :title, :minimum => 3
  validates_length_of :author, :minimum => 3
  #validates_numericality_of :pages, :only_integer => true
  #validates_uniqueness_of :isbn
  
  def self.per_page
    50
  end
  
  def discount?
    discount
  end
  
  def discard_empty_isbn
    if (isbn == '')
      self.isbn = nil;
    end
  end
  
  def discount_price
    if price < 50
      sale_price = (price*0.88).ceil #ceil
    else
      sale_price = (price*0.88).floor #floor
    end
    sale_price
  end
  
  def self.search(keyword, page)
    self.paginate :page => page, :conditions => ["(author LIKE ?) OR (title LIKE ?)", '%'+keyword+'%', '%'+keyword+'%'], :order =>"id DESC" 
  end
  
end
