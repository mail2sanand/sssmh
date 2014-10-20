class DoctorController < ApplicationController
  include AuthenticatedSystem
  include DoctorHelper
#  include CacheExpirationHelper
  
#  cache_sweeper :user_sweeper

  before_filter :login_required, :except => []

#  layout 'ms_project_layout', :except => [:index,:doctor_details]
  
  layout 'doctor_profile_layout', :except => [:index]
#  caches_action :index
  
  def index
    @approved_doctors = User.approved
#    @approved_doctors = User.get_all_approved_users
#    @approved_doctors = get_all_approved_users
#    puts "@approved_doctors : #{@approved_doctors.collect(&:full_name)}"
  end
  
  def doctor_details
    docs_to_be_printed = params[:docs_to_be_printed]
    doc_ids = docs_to_be_printed.split(",")
    
    @doctor_profiles = []
    for each_doc_id in doc_ids
      each_doctor = {}
      each_doctor["general_profile"] = User.find(each_doc_id)
      each_doctor["professional_profile"] = each_doctor["general_profile"].user_professional_detail
      @doctor_profiles << each_doctor
    end
    
#    doctor_profiles = prepare_doctor_profiles(docs_to_be_printed)
  end
  
end
