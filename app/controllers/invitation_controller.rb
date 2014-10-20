require 'net/http'
require "rexml/document"
require "uri"
require 'thread'

class InvitationController < ApplicationController
  include AuthenticatedSystem
  include InvitationHelper
  include SmsHelper

  before_filter :login_required,:except => [:recieve_sms]

  def invite_docs
    @schedule_id = params[:schedule_id]
    @programme_name = params[:programme_name]

    @non_volunteered_docs = User.non_volunteered_docs(@schedule_id)
    @user_specializations = get_user_specializations_hash(@non_volunteered_docs)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def invite_this_doc
    
    @schedule_id = params[:schedule_id]
    @user_id = params[:user_id]
    @programme_name = params[:programme_name]
    @end_date = 

    @success = User.invite_user_for_schedule(@user_id,@schedule_id)
        
    schedule = Schedule.find(@schedule_id)
    @end_date = schedule.end_date
    @non_volunteered_docs = User.non_volunteered_docs(@schedule_id)
    @non_volunteered_user_specializations = get_user_specializations_hash(@non_volunteered_docs)
    
    @users_volunteered_for_this_schedule, @users_invited_for_this_schedule,@volunteered_user_specializations = get_invited_and_volunteers_users(@schedule_id)
    
    if @success != false
      message_info = Hash.new
      message_info[:programme_name] = @programme_name
      message_info[:user_phone_number] = @success.contact_mob_no
      message_info[:user_name] = @success.full_name
      message_info[:schedule_start_date] = schedule.start_date
      message_info[:schedule_end_date] = schedule.end_date

      Thread.new{
        send_message_to_this_doc(message_info)
      }
      
      Thread.new{
        mail_subject_and_body = ""
        if message_info[:schedule_start_date] == message_info[:schedule_end_date]
          mail_subject_and_body = "#{message_info[:user_name]}(#{message_info[:user_phone_number]}) has been invited for the programme #{message_info[:programme_name]} happening on #{message_info[:schedule_start_date].strftime("%b %d %Y")}"
        else
          mail_subject_and_body = "#{message_info[:user_name]}(#{message_info[:user_phone_number]}) has been invited for the programme #{message_info[:programme_name]} happening between #{message_info[:schedule_start_date].strftime("%b %d %Y")} and #{message_info[:schedule_end_date].strftime("%b %d %Y")}"
        end

        UserNotifications.deliver_mail_to_admin_about_invite_doctor(mail_subject_and_body)
      }

    end
    
#    send_message_to_this_doc_via_way2sms(@programme_name,@success) if @success != false
#    send_message_to_this_doc_via_sendsmsnow(@programme_name,@success) if @success != false
    
    respond_to do |format|
      format.html
      format.js
    end
    
  end
  
  def approve_reject_this_doc
    @schedule_id = params[:schedule_id]
    @user_id = params[:user_id]
    @programme_name = params[:programme_name]
    @approve_reject = params[:approve_reject]

    @success = User.approve_reject_user_for_schedule(@user_id,@schedule_id,@approve_reject)
        
    schedule = Schedule.find(@schedule_id)
    @end_date = schedule.end_date
    @non_volunteered_docs = User.non_volunteered_docs(@schedule_id)
    @user_specializations = get_user_specializations_hash(@non_volunteered_docs)
    @users_volunteered_for_this_schedule, @users_invited_for_this_schedule,@volunteered_user_specializations = get_invited_and_volunteers_users(@schedule_id)
    
    if @success != false
      Thread.new{
        message_info = Hash.new
        message_info[:programme_name] = @programme_name
        message_info[:user_phone_number] = @success.contact_mob_no
        message_info[:schedule_start_date] = schedule.start_date
        message_info[:schedule_end_date] = schedule.end_date
        send_message_to_this_doc(message_info)
      }
    end
    
    respond_to do |format|
      format.html
      format.js
    end
    
  end
  
  def recieve_sms
    msisdn = params[:msisdn]
    content = params[:content]
    
    render :text => "<b>msisdn = #{msisdn} <br> content = #{content}</b>"
  end
  
  def recieve_sms_from_sms2mint
    @processed_sms,@deleted_sms = recieve_sms_from_sms2mint_through_web

    respond_to do |format|
      format.html
      format.js
    end

  end
  
  private
    
end
