class UserController < ApplicationController
  before_filter :login_required, :except => []

  layout 'ms_project_layout', :except => []
  
  def forgot_password
#    begin
      user_name=params[:user_name]
      if user=User.find_by_user_name(user_name)
        UserNotifications.deliver_forgot_password(user)
        text="To Reset your Password, please click on the link sent to your Primary E-Mail ID."
      else
        text="This User does not seem to Exist. Please check the username you have provided"
      end
      render :text=>text
#    rescue
#    end
  end
  
end
