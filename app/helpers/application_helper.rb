# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  MEGABYTE = 1024.0 * 1024.0
  
  def bytesToMeg bytes
    bytes /  MEGABYTE
  end
  
end
