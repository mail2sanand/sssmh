require "date"
class ScheduleController < ApplicationController
include InvitationHelper

  def index
    @user_type = session[:user][:user_role]
    
    @partial = params[:just_partial]
    schedules = Schedule.find(:all,
                              :include => [:user_schedules],
                              :select => "schedules.*, user_schedules.*",
                              :order => "start_date ASC")
    
    logged_in_user = User.find(session[:user][:user_id])
    @user_approved = logged_in_user.is_approved?

    @active_schedules = Array.new
    @expired_schedules = Array.new
    
    for each_schedule in schedules
      @schedules_hash = Hash.new
      @schedules_hash[:id] = each_schedule.id
      volunteer_type,@schedules_hash[:user_status] = logged_in_user.volunteer_type_and_status(each_schedule.id)
      @schedules_hash[:user_message] = user_message(volunteer_type,@schedules_hash[:user_status],each_schedule.end_date)
      @schedules_hash[:volunteer_type] = volunteer_type
      @schedules_hash[:user_is_invited] = (volunteer_type and volunteer_type.split(" ")[0] == "Invited" ? true : false)
      @schedules_hash[:user_is_volunteer] = ((volunteer_type == "volunteered") ? true : false)
#      @schedules_hash[:user_is_volunteer] = each_schedule.user_schedules.map(&:user_id).include?(session[:user][:user_id])
      @schedules_hash[:programme_name] = each_schedule.programme_name
      @schedules_hash[:location_id] = each_schedule.location_id.gsub(/,/,"<br>")+"<br>"+each_schedule.other_locations
      @schedules_hash[:specializations] = each_schedule.get_specializations
      @schedules_hash[:start_date] = each_schedule.start_date
      @schedules_hash[:end_date] = each_schedule.end_date
      
      if each_schedule[:end_date].to_s < Date.today.strftime("%Y-%m-%d")
        @expired_schedules << @schedules_hash
      else
        @active_schedules << @schedules_hash
      end
      
    end
  end
  
  def schedule_a_programme
    @locations = Location.find(:all)
    @specializations = Specialization.find(:all)
    @location_hash = {}
    @location_hash_string  = ""

=begin
Format of location_hash in Ruby 1.9.1 is as below.
{1=>"Marakunta Palli", 2=>"Byrapuram", 3=>"Kotala Palli", 4=>"Rachuvarapalli", 5=>"Cherla Palli", 6=>"Kondakamrala", 7=>"Chowkunta Palli", 
8=>"Vaskarakunta", 9=>"Veldurthy", 10=>"Mylasamudram", 11=>"Marala", 12=>"Chandrayana Palli", nil=>"Others"}

Format of location_hash in Ruby 1.8.7 is 
5Cherla Palli11Marala6Kondakamrala12Chandrayana Palli1Marakunta PalliOthers7Chowkunta Palli2Byrapuram8Vaskarakunta3Kotala Palli9Veldurthy4Rachuvarapalli10Mylasa
mudram   
=end
    
    for each_location in @locations
      # The below format is compatible with the Ruby 1.8.7 version.
      @location_hash_string = @location_hash_string + "#{each_location.day_of_the_month}" + "=>" + each_location.location_name.to_s+","
      
      # Below is the format comfortable with Ruby 1.9.1
      # @location_hash[each_location.day_of_the_month.to_i] = each_location.location_name.to_s 
    end
    

    @location_hash = @location_hash_string[0,(@location_hash_string.length-1)]
    
    @error_messages = ""
    
    if !params[:schedule].nil?
#      params[:schedule]["specializations"] = params[:schedule]["specializations"].to_s
      @new_schedule = Schedule.new(params[:schedule])
  #      schedule_saved = @new_schedule.save!
  #      puts "schedule_saved  : #{schedule_saved}"
      if @new_schedule.valid?
        @new_schedule.save!
        @error_messages = "The Schedule \"#{params[:schedule]["programme_name"]}\" was successfuly created"
      else
        @error_messages = get_error_messages(@new_schedule)
      end
    end
    
  end
  
  def create_schedule_for_a_programme
    @error_messages = ""
    specializations_array = params[:schedule]["specializations"]
    
    params[:schedule]["specializations"] = params[:schedule]["specializations"].join(",") if specializations_array 
    @new_schedule = Schedule.new(params[:schedule])
    
    if @new_schedule.valid?
      @new_schedule.save!
      @error_messages = "The Schedule \'#{params[:schedule]["programme_name"]}\' was successfuly created"
    else
      @error_messages = get_error_messages(@new_schedule)
    end
    
    respond_to do |format|
      format.html 
      format.js
    end
    
  end
  
  def schedule_config_form;end;
    
  def volunteer_for_schedule
    @schedule_id = params[:schedule_id]
    @programme_name = params[:programme_name]
    @background_class = params[:background_class]
    @volunteer_type = params[:volunteer_type]
    @accept_reject = params[:accept_reject]
    
    @from_where = params[:from_where]
    @user_id = params[:user_id]
    
    if @from_where == 'admin'
      user_id = @user_id
    else
      user_id = session[:user][:user_id]
    end
   
    @success_failure=""
    @message = ""
    @div_to_update = ""
    begin
      if @volunteer_type == "volunteer"
        UserSchedule.create({:user_id => session[:user][:user_id], :schedule_id => @schedule_id.to_i})
        @message = "You have been successfully registered for the programme \'#{@programme_name}\'"
      elsif @volunteer_type == "in_volunteer"
        UserSchedule.find_by_schedule_id_and_user_id(@schedule_id.to_i,session[:user][:user_id]).destroy
        @success_failure = ""
        @message = "You have been successfully un-registered for the programme \'#{@programme_name}\'"
      elsif @accept_reject == "accept"
          UserSchedule.find_by_schedule_id_and_user_id(@schedule_id.to_i,user_id).update_attribute("volunteered",1)
          @success_failure="success"
          @message = "You have accepted the invitation and have been successfully regstered for the programme \'#{@programme_name}\'"
      elsif @accept_reject == "reject"
        UserSchedule.find_by_schedule_id_and_user_id(@schedule_id.to_i,user_id).update_attribute("volunteered",-1)
        @message = "You have declined the invitation for the programme \'#{@programme_name}\'"
      end
      
      @div_to_update = "&lt;input type=\"checkbox\" &gt;"
        
    if @from_where == 'admin'
      @users_volunteered_for_this_schedule, @users_invited_for_this_schedule,@non_volunteered_user_specializations = get_invited_and_volunteers_users(@schedule_id)
      @non_volunteered_docs = User.non_volunteered_docs(@schedule_id)
      @user_specializations = get_user_specializations_hash(@non_volunteered_docs)
      
      # This is just to make sure that the end_date variable is more than today's date.
      @end_date = Date.today+7
    end
    
    rescue Exception => e
      @success_failure = "fail"
      @message = "Sorry, Due to some technical problem, You have ne=ot been registered for this Schedule. <br>The administrator has been notified of this. We will get back shortly."
    end
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def view_volunteers_for_this_schedule
    
    @schedule_id = params[:schedule_id]
    @programme_name = params[:programme_name]
    @end_date = params[:end_date]
    
    @users_volunteered_for_this_schedule, @users_invited_for_this_schedule,@non_volunteered_user_specializations = get_invited_and_volunteers_users(@schedule_id)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def schedule_management
    
  end
  
end
