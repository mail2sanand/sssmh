module DoctorHelper
  def prepare_doctor_profiles(doc_ids)
    doctor_ids_array = doc_ids.split(",")

    doctor_profiles = []
    for each_doc in doctor_ids_array
      each_doc_profile = {}
      each_doc_record = User.find(each_doc)
      each_doc_professional_record = each_doc_record.user_professional_detail
      each_doc_profile["full_name"] = each_doc_record.full_name
      each_doc_profile["user_id"] = each_doc_record.user_id
      each_doc_profile["gender"] = each_doc_record.gender
      each_doc_profile["age"] = each_doc_record.age
      each_doc_profile["email"] = each_doc_record.email
      each_doc_profile["specialization"] = each_doc_professional_record.get_specialization
      each_doc_profile["doctor_rating"] = each_doc_record.rating
      each_doc_profile["certificate_url"] = each_doc_professional_record.certificate.url
      each_doc_profile["contact_mob_no"] = each_doc_record.contact_mob_no
      each_doc_profile["contact_home_no"] = each_doc_record.contact_home_no
      each_doc_profile["address"] = each_doc_record.address
      each_doc_profile["sss_org_association"] = each_doc_record.sss_org_association
      each_doc_profile["sss_org_association_details"] = each_doc_record.full_name
      each_doc_profile["volunteer_activity"] = each_doc_record.volunteer_activity
      
    end
    
  end
  
end
