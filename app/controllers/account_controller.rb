#require 'rubygems'
#require 'pdf/reader'

class AccountController < ApplicationController

#  This prawnto rails plugin is for PDF generation toolkit in rails.
#  prawnto :prawn => { :top_margin => 75,:page_size => 'A4', :inline => true }

  #Included for the acts_as_authenticated plugin ...
  include ApplicationHelper
  
  include AuthenticatedSystem
  include DoctorRatingHelper

  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :login_required, :except => [:login,:signup]

  layout 'ms_project_layout', :except => [:approve_user,:sample_action,:update_profile,:change_password]

  def user_details
    
    @user = User.find(params[:user])
    
    respond_to do | format |
     format.pdf { render :format=>false}
    end
   
  end
  
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
    @user_type = session[:user][:user_role]
    @users = User.approved

#    puts "======================="
#    puts @users.each{|u| u.}
    @users_to_be_approved = User.to_be_approved
  end
  
  #This method is used for approving and rejecting users.
  def approve_user
    users_to_be_approved = params[:users_to_be_approved]
    users_to_be_rejected = params[:users_to_be_rejected]

    approve = params[:approve]

    flash[:notice] = ""

    #This block is to handle the users to be approved ...
      unless users_to_be_approved.nil?
        users_to_be_approved = users_to_be_approved.map(&:to_i)
        User.find(users_to_be_approved).each do |each_user|
          each_user.update_attribute('approved',true)
          Thread.new{
            UserNotifications.deliver_user_approved(each_user)
          }
#          puts "#{each_user.full_name} approved ..."
        end

        flash[:notice] += "#{users_to_be_approved.length} users Successfully Approved"
        
      else
        flash[:notice] += "No Users Selected for Approval"
      end
    #Till Here

    #This block is to handle the users to be rejected ...
      unless users_to_be_rejected.nil?
        users_to_be_rejected = users_to_be_rejected.map(&:to_i)
        User.find(users_to_be_rejected).each do |each_user|
          each_user.update_attribute('approved',false)
        end

        flash[:notice] += "</br>#{users_to_be_rejected.length} users Successfully Rejected"
      else
        flash[:notice] += "</br>No Users Selected for Rejection"
      end
    #Till Here

    @users = User.approved
    @users_to_be_approved = User.to_be_approved

    respond_to do |format|
      format.html {redirect_to :index}
      format.js
    end

  end

  def get_picture
    user_id = (params[:user_id] ? params[:user_id] : session[:user][:user_id])
#    puts "user_id : #{user_id}"
    
    user_photo = User.find(
                            :first,
                            :conditions=>["user_id = ?",user_id]
                          )
                            
    if user_photo.photo == nil or user_photo.photo.empty?
    	#If the image cannot be found display the image 'No Image Found'
    	images_path = File.expand_path(File.dirname(__FILE__) + "/../../public/images" )
    	send_file images_path + '/image.gif' , :type => 'image/gif', :disposition => 'inline'
	  else
      send_data(user_photo.photo,:disposition => "inline")
    end
  end
  
  def get_certificate
    user_id = (params[:user_id] ? params[:user_id] : session[:user][:user_id])
    certificate_path = params[:certificate_path]
    
    certificate_path = "#{RAILS_ROOT}/public/"+certificate_path
    if File.exist?(certificate_path)
      send_file(certificate_path,:disposition => "inline")
    else
      render :text => "Sorry, the file you are searching for was not found. We have taken a note of this and will revert. <br>We seriously regret for the inconvenience"
    end
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @user = User.new(params[:user])
    
    # This is to populate the Full Name with Dr. initially
    unless params[:user]
      @user.full_name = "Dr. "
    end
    
    @user_professional_detail = UserProfessionalDetail.new(params[:user_professional_detail])
    
    return unless request.post?

    unless params[:user_professional_detail].nil?
      params[:user_professional_detail][:volunteer_activity] = params[:user][:volunteer_activity]
      params[:user_professional_detail][:residing_disance_from_ptp] = params[:user][:residing_disance_from_ptp]
      params[:user_professional_detail][:doctors_referral] = params[:user][:doctors_referral]
    end
    
     user_errors = (@user.valid? ? "" : get_error_messages(@user,false))   
     user_professional_errors = (@user_professional_detail.valid? ? "" : get_error_messages(@user_professional_detail,false))
    
     overall_errors = user_errors + user_professional_errors
      
      #If both the User and User Professional Details are valid.
      if overall_errors.empty?
        @user.save!
        
        #Saving the User Professional Detail 
        @user_professional_detail[:user_id] = @user.id
        @user_professional_detail[:certificate_file_name] = "#{params[:user_professional_detail][:uploaded_certificate].original_filename}" 
        @user_professional_detail[:certificate_content_type] = params[:user_professional_detail][:uploaded_certificate].content_type.chomp.upcase
        @user_professional_detail[:certificate_file_size] = params[:user_professional_detail][:uploaded_certificate].size
        @user_professional_detail.save!
        
        #Saving the User Rating ...
        doctors_rating = calculate_doctors_rating(params[:user_professional_detail])
        @user_rating = UserRating.new(doctors_rating)
        @user_rating[:user_id] = @user.id
        @user_rating.save!
        
        self.current_user = @user
        redirect_back_or_default(:controller => '/account', :action => 'index')
        flash[:notice] = "Thanks for signing up!"
      end
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def edit
    @user = User.find_by_user_id(session[:user][:user_id]).reload
  end
  
  def assign_user_with_attributes(user,user_attributes)
    user[:gender] = user_attributes[:gender]
    user[:age] = user_attributes[:age]
    user[:email] = user_attributes[:email]
    user[:full_name] = user_attributes[:full_name]
    user[:address] = user_attributes[:address]
    user[:sss_org_association] = user_attributes[:sss_org_association]
    user[:sss_org_association_details] = user_attributes[:sss_org_association_details]
    user[:contact_mob_no] = user_attributes[:contact_mob_no]
    user[:contact_home_no] = user_attributes[:contact_home_no]
    user[:possible_freq_of_visit] = user_attributes[:possible_freq_of_visit]
    user[:possible_duration_of_visit] = user_attributes[:possible_duration_of_visit]
    user[:volunteer_activity] = user_attributes[:volunteer_activity]
    user[:volunteer_activity_details] = user_attributes[:volunteer_activity_details]
    user[:residing_disance_from_ptp] = user_attributes[:residing_disance_from_ptp]
    user[:doctors_referral] = user_attributes[:doctors_referral]
    user[:comments] = user_attributes[:comments]
    user.uploaded_picture = user_attributes[:uploaded_picture]
    user
  end
  
  def assign_user_prof_detail_with_attributes(user_professional_detail,user_professional_detail_attributes)
    user_professional_detail[:designation] = user_professional_detail_attributes[:designation]
    user_professional_detail[:specialization] = user_professional_detail_attributes[:specialization]
    user_professional_detail[:qualification] = user_professional_detail_attributes[:qualification]
    user_professional_detail[:institution_name] = user_professional_detail_attributes[:institution_name]
    user_professional_detail[:type_of_practice] = user_professional_detail_attributes[:type_of_practice]
    user_professional_detail[:medical_registration_number] = user_professional_detail_attributes[:medical_registration_number]
    user_professional_detail[:reporting_authority_and_designation] = user_professional_detail_attributes[:reporting_authority_and_designation]
    user_professional_detail[:working_dept] = user_professional_detail_attributes[:working_dept]
    user_professional_detail[:years_of_exp] = user_professional_detail_attributes[:years_of_exp]
    user_professional_detail[:research_interest] = user_professional_detail_attributes[:research_interest]
    user_professional_detail[:research_details] = user_professional_detail_attributes[:research_details]
    user_professional_detail[:papers_published] = user_professional_detail_attributes[:papers_published]
    user_professional_detail[:special_training] = user_professional_detail_attributes[:special_training]
    user_professional_detail[:special_training_details] = user_professional_detail_attributes[:special_training_details]
    user_professional_detail[:special_conf_attended] = user_professional_detail_attributes[:special_conf_attended]
    user_professional_detail[:special_conf_attended_details] = user_professional_detail_attributes[:special_conf_attended_details]
    user_professional_detail[:own_clinic_or_hospital] = user_professional_detail_attributes[:own_clinic_or_hospital]
    user_professional_detail[:treatments_offered] = user_professional_detail_attributes[:treatments_offered]
    user_professional_detail[:equipments_available] = user_professional_detail_attributes[:equipments_available]
    user_professional_detail[:beds_count] = user_professional_detail_attributes[:beds_count]
    user_professional_detail.uploaded_certificate = user_professional_detail_attributes[:uploaded_certificate] if !user_professional_detail_attributes[:uploaded_certificate].nil?
    user_professional_detail.edit_profile = true
    user_professional_detail
  end
  
  
  def update_profile
    @user = User.find_by_user_id(session[:user][:user_id])
    user_attributes = assign_user_with_attributes(@user,params[:user])
    user_errors = (user_attributes.valid? ? "" : get_error_messages(user_attributes,false))
    
    u_p_d = @user.user_professional_detail
    if u_p_d
      @user_professional_detail = u_p_d 
      user_professional_attributes = assign_user_prof_detail_with_attributes(@user_professional_detail,params[:user_professional_detail])
      
      user_professional_errors = (user_professional_attributes.valid? ? "" : get_error_messages(user_professional_attributes,false))
#      puts "=================================================================================================================================="
    else
      user_professional_errors = "User Professional Detail record not found for this user."
    end
    
    @overall_errors = user_errors + user_professional_errors

    #If both the User and User Professional Details are valid.
    if @overall_errors.empty?
      user_attributes.save!
      user_attributes.update_attribute("uploaded_picture",user_attributes[:uploaded_picture])
      u_p_d.update_attributes(params[:user_professional_detail]) if u_p_d
#      user_professional_attributes.save! if 
#      user_professional_attributes.update_attribute("uploaded_certificate",user_professional_attributes[:uploaded_certificate])
      
#      @user.user_professional_detail.update_attributes(params[:user_professional_detail]) if @user.user_professional_detail
      
      params[:user_professional_detail][:volunteer_activity] = params[:user][:volunteer_activity]
      params[:user_professional_detail][:residing_disance_from_ptp] = params[:user][:residing_disance_from_ptp]
      params[:user_professional_detail][:doctors_referral] = params[:user][:doctors_referral]
      doctors_rating = calculate_doctors_rating(params[:user_professional_detail])
      @user.user_rating.update_attributes(doctors_rating)
    end
    
#    puts "format Type : #{request.format}"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => 'home', :action => 'index')
  end

  def change_password
    password_list = params[:password_list]
    @user = User.find(session[:user][:user_id])
    @error_message = @user.verify_and_update_passwords(password_list)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def sample_action_create
    puts "sample_action_create action"
  end
  
  def sample_action
    puts "Comming in the sample_action, Request Format : #{request.format} "
    puts "PPPPPPPPPPPPPPPP #{params[:sample_form][:upload_file]}"
    puts "PPPPP #{params[:sample_form][:sample_text]}"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
end
