class HomeController < ApplicationController

  include HomeHelper

  layout 'ms_project_layout', 
    :except => [:about_the_programme,:training_module, :about_us, :news_and_events, :testimonials, :image_gallery,:programme_statistics, :newsletters, :upload_newsletters_form]
  
  def index; end
    
  def about_the_programme; end
    
  def training_module; end
  
  def about_us; end
  
  def news_and_events; end
    
  def testimonials; end
    
  def image_gallery; end
  
  def programme_statistics; end
  
  def newsletters
   @yearwise_articles = arrange_by_year(Newsletter.find(:all,:order => "id asc")) 
  end

  def download_newsletter
    
    newsletter_name = params[:newsletter_name]+".pdf"
    newsletters_folder_location = File.join(RAILS_ROOT,"public","newsletters/")
    newsletter_location = newsletters_folder_location + newsletter_name
    if File.exists?(newsletter_location)
      send_file(newsletter_location,:disposition => "inline")
    end
  end
  
  def upload_newsletters_form
    
  end
  
end
