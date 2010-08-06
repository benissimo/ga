# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
  
class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  

  
  helper_method :iphone_user_agent?

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '135712a6c4648d974466e9ab3b2adf0a'
    
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private
  def authorize
    unless session[:user_id]
      flash[:notice] = "Please log in"
      redirect_to(:controller=>'admin/login', :action => 'login')
    end
  end

  protected
  def adjust_format_for_iphone
    # iPhone sub-comain request
    # request.format = :iphone if iphone_subdomain?
    
    # Detect from iPhone user-agent    
    request.format = :iphone if iphone_user_agent?
  end
  
  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
  
  def iphone_subdomain?
    return request.subdomains.first == 'iphone'
  end

end
