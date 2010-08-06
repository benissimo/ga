class User < ActiveRecord::Base
  
  def self.login(name, password)
    find(:first,
          :conditions => ["name = ? and password = ?",
                            name, password])
  end

  def try_to_login
    User.login(self.name, self.password)
  end
end
