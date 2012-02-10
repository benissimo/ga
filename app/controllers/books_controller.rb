class BooksController < ApplicationController
      
  before_filter :authorize, :only => [:show, :new, :edit, :create, :update, :destroy]    

  before_filter :adjust_format_for_iphone
  before_filter :adjust_pagination_for_iphone

  before_filter :category_nav, :except => [:legacy, :create, :update, :destroy]
  caches_action :category_nav
  
  # GET /books
  # GET /books.xml
  def index

    if request.format == :iphone
      logger.info("loading categories for iphone request")
      @categories = Category.all(:order=>"name")
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.iphone # index.iphone.erb
      #format.xml  { render :xml => @books }
    end
  end

  def list
    @cat = Category.find(:first, :conditions => ["name = ?", params[:id]])
    @title = @cat.name.capitalize
    @query = nil
    @books = Book.paginate :page => params[:page], :conditions => ["category_id = ?", @cat.id], :order =>"title"

    respond_to do |format|
      format.html # *.html.erb
      format.iphone { render :layout => false } # *.iphone.erb
      #format.xml  { render :xml => @books }
    end
  end

  def recent
    @title = 'Novità'
    @query = nil
    @books = Book.paginate :page => params[:page], :conditions => "special_offer = TRUE", :order =>"id DESC"
    #render :action => 'list'
    respond_to do |format|
      format.html { render :action => 'list'}# *.html.erb
      format.iphone { render :layout => false, :action => 'list' } # *.iphone.erb
      #format.xml  { render :xml => @books }
    end
  end

  def offers
    @title = 'Sconti'
    @query = nil
    @books = Book.paginate :page => params[:page], :conditions => "discount = TRUE", :order =>"id DESC"
    #render :action => 'list'
    respond_to do |format|
      format.html { render :action => 'list'}# *.html.erb
      format.iphone { render :layout => false, :action => 'list' } # *.iphone.erb
      #format.xml  { render :xml => @books }
    end    
  end


  # GET /books/order/1
  # POST /books/order/1
  def order
    @book = Book.find(params[:id])
    #if request.get?
    unless validate_order params
      # just display form
      respond_to do |format|
        format.html # order.html.erb
        format.iphone { render :layout => false } # *.iphone.erb
        #format.xml  { render :xml => @books }
      end
    else
      SiteMailer.deliver_book_request(params,@book)
      #email = SiteMailer.create_book_request(params,@book)
      #render(:text => "<pre>" + params[:email] + "</pre>")
      respond_to do |format|
        format.html {
          flash[:notice] = "Grazie, ti contatteremo al pi&ugrave; presto!"
          redirect_to('/') 
          }
        format.iphone { render(:text => "<ul title='Grazie'><li>Grazie!, ti contatteremo al pi&ugrave; presto.</li><li><a href='/' target='_self'>Continua</a></li></ul>")}
      end
    end
    
  end

  # GET /books/1
  # GET /books/1.xml
  def show
    @book = Book.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @book }
    end
  end

  def search
    if params[:search]
      @title = "Results for '"+params[:search][:q]+"'"
      @query = params[:search][:q]
#      @books = Book.paginate :page => params[:page], :conditions => [((params[:search][:type] == 'author') ? "author" : "title") + " LIKE ?", '%'+params[:search][:q]+'%'], :order =>"id DESC"
      @books = Book.search(params[:search][:q], params[:page])

      #render :action => 'list'   
      respond_to do |format|
        format.html { render :action => 'list'}# *.html.erb
        format.iphone { render :layout => false, :action => 'list' } # *.iphone.erb
        #format.xml  { render :xml => @books }
      end   
    else
      # display search form
    end
  end
  
  # redirects for old urls
  def legacy
    case params[:path][0]
    when 'list'
        if (params[:path][1] == 'novita.php')
          redirect_to :controller => 'books', :action => 'recent'
        elsif (params[:path][1] == 'sconti.php')
          redirect_to :controller => 'books', :action => 'offers'
        else
          redirect_to :controller => 'books', :action => 'list', :id => params[:path][1].sub('.php','').sub('_',' ')
        end
    when 'search.php'
      redirect_to :controller => 'books', :action => 'search'
    when 'links.php'
      redirect_to :controller => 'books', :action => 'links'
    else
      redirect_to '/'        
    end
  end
  
  # GET /books/new
  # GET /books/new.xml
  def new
    @book = Book.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @book }
    end
  end

  # GET /books/1/edit
  def edit
    @book = Book.find(params[:id])
  end

  # POST /books
  # POST /books.xml
  def create
    @book = Book.new(params[:book])

    respond_to do |format|
      if @book.save
        flash[:notice] = 'Book was successfully created.'
        format.html { redirect_to(@book) }
        format.xml  { render :xml => @book, :status => :created, :location => @book }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /books/1
  # PUT /books/1.xml
  def update
    @book = Book.find(params[:id])

    respond_to do |format|
      if @book.update_attributes(params[:book])
        flash[:notice] = 'Book was successfully updated.'
        format.html { redirect_to(@book) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.xml
  def destroy
    @book = Book.find(params[:id])
    @book.destroy

    respond_to do |format|
      format.html { redirect_to(books_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def category_nav
      unless read_fragment(:action => 'category_nav')
        logger.info("creating fragment category nav")
        logger.info(ActionController::Base.cache_store)
        @categories = Category.all(:order=>"name")
      end  
  end


  def adjust_pagination_for_iphone
    if request.format == :iphone
      # redefine Book class method 'per_page'
      def Book.per_page
        10
      end
      # page, next instance variables needed for iphone style pagination
      if params[:page] 
        @page = Integer params[:page]
      else
        @page = 1
      end
      @next = @page + 1
    end
  end

  # This isn't much of a validation method...
  def validate_order params
    return false unless params[:email].present? && params[:email] =~ /[^@]+@[^@]+/
    # cheapo regex for email, not really trying to filter, just catch typos: missing or too many @s.
    return false if params[:phone].present? && params[:phone].gsub(/\D/,'').length < 7
    # a lot of spam bots post phone numbers as random series of letters. this is a cheap way of
    # catching that without having to print a captcha or ask a question.
    return true
  end
end
