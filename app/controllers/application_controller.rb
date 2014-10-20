# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#include NewMath
#include ApplicationHelper

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

   #
    #This method sorts the error messages on an active record object and returns a html unordered list element of them
    #
    def get_error_messages(object,heading=true)
      error_msgs = ""   
      if object.errors != nil && ! object.errors.empty?
        sorted_errors = object.errors.sort do |err_a, err_b|
          err_a[0].downcase <=> err_b[0].downcase  
        end     
        error_msgs += '<b>Please correct the following errors before proceeding:</b>' if heading == true
        error_msgs += '<ul>'
        sorted_errors.each do |attr, msg|
          error_msgs += '<li>' + attr.split("_").map(&:capitalize).join(" ") +" "+ msg + '</li>'
        end
      end 
        
      error_msgs
    end   


end
