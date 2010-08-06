class SiteMailer < ActionMailer::Base
  
    def book_request(params, book)
        recipients ['webmaster@galileoalby.com','benissimo@gmail.com']
        from params[:email]
        reply_to params[:email]
        subject "GalileoAlby.com -- richiesta"
        sent_on Time.now
        body :params => params, :book => book

  #      attachment :content_type => "application/pdf", :body => File.read("path.to.pdf")
    end
    
end
