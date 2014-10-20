module InvitationHelper
  
  def get_invited_and_volunteers_users(schedule_id)
    
    user_volunteers_for_this_schedule = Schedule.find(schedule_id).users
    
    users_volunteered_for_this_schedule = Array.new
    users_invited_for_this_schedule = Array.new
    
    users_for_getting_specializations_hash = []
    
    for each_user in user_volunteers_for_this_schedule
      each_user_hash = Hash.new
      each_user_hash[:user_id] = each_user.user_id
      each_user_hash[:full_name] = each_user.full_name
      each_user_hash[:photo] = each_user.photo.nil?
      each_user_hash[:email] = each_user.email
      each_user_hash[:age] = each_user.age
      each_user_hash[:gender] = each_user.gender
      each_user_hash[:contact_mob_no] = each_user.contact_mob_no
      each_user_hash[:specializations] = (each_user.user_professional_detail ? Specialization.find(each_user.user_professional_detail.specialization.to_i).name : "Not Specified")
      each_user_hash[:invited],each_user_hash[:status] = each_user.volunteer_type_and_status(schedule_id)
      
      users_for_getting_specializations_hash << each_user_hash 
      
      if each_user_hash[:invited] and (each_user_hash[:invited] == "Invited and Waiting" or each_user_hash[:invited] == "Invited and Rejected") 
        users_invited_for_this_schedule << each_user_hash
      else
        users_volunteered_for_this_schedule << each_user_hash
      end
      
    end
    
    return users_volunteered_for_this_schedule,users_invited_for_this_schedule,get_user_specializations_hash(users_for_getting_specializations_hash)
    
    
  end
  
  def user_message(volunteer_type,user_status,end_date)
    user_message = ""
    if end_date.to_s < Date.today.strftime("%Y-%m-%d")
      user_message = "Programme Completed"
    elsif volunteer_type and volunteer_type.split(" ")[0] == "Invited"
      user_message = volunteer_type
    elsif volunteer_type == "volunteered" and user_status == 1
      user_message = "Approved"
    elsif volunteer_type == "volunteered" and user_status == -1
      user_message = "Rejected by Admin"
    elsif volunteer_type == "volunteered" and user_status == 0
      user_message = "Waiting for Admin's Approval"
    end
    user_message        
  end
  
  def get_user_specializations_hash(users)
    user_specializations_hash = Hash.new
    
    if users
      i=0
      for each_user in users
        each_user_specialization = each_user.respond_to?('specializations') ? each_user.specializations.downcase.strip : each_user[:specializations].downcase.strip
        
        if !user_specializations_hash.has_key?(each_user_specialization)
          user_specializations_hash[each_user_specialization] = [i,[]]
#          user_specializations_array << i
          i+=1
        end
        
        user_specializations_hash[each_user_specialization][1] << (each_user.respond_to?('user_id') ? each_user.user_id : each_user[:user_id])
      end
    end
    
    user_specializations_hash
    
  end
  
end
