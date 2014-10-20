
module DoctorRatingHelper
   @@doctor_rating_values = YAML.load(File.open("#{RAILS_ROOT}/config/doc_rating_config.yml"))
   
  def calculate_doctors_rating(user)
    doctors_rating_hash = Hash.new
    doctors_rating_hash['doctors_qualification_rating'] = user[:qualification].nil? ? 0 : @@doctor_rating_values["doctors_qualification"][user[:qualification].downcase.gsub(/\ |\//,"_").squeeze]
    doctors_rating_hash['qualification_from_which_institution_rating'] = user[:institution_name].empty? ? 0 : calculate_qualification_from_which_institution_rating(user[:institution_name].downcase.gsub(/\ |\//,"_").squeeze)
    doctors_rating_hash['years_of_experience_rating'] = user[:years_of_exp].empty? ? 0 : @@doctor_rating_values["years_of_experience"][user[:years_of_exp]]
    doctors_rating_hash['type_of_practice_rating'] = user[:type_of_practice].empty? ? 0 : @@doctor_rating_values["type_of_practice"][user[:type_of_practice].downcase.gsub(/\ |\//,"_").squeeze]
    doctors_rating_hash['research_interest_rating'] = user[:research_interest].to_i==1 ? @@doctor_rating_values["research_interest"][true] : @@doctor_rating_values["research_interest"][false]
    doctors_rating_hash['voluntary_medical_activity_in_24_months_rating'] = user[:volunteer_activity].to_i==1 ? @@doctor_rating_values["voluntary_medical_activity_in_24_months"][true] : @@doctor_rating_values["voluntary_medical_activity_in_24_months"][false]
    doctors_rating_hash['own_a_hospital_rating'] = user[:own_clinic_or_hospital].to_i==1 ? @@doctor_rating_values["own_a_hospital"][true] : @@doctor_rating_values["own_a_hospital"][false]
    doctors_rating_hash['residing_distance_from_puttaparthi_rating'] = user[:residing_disance_from_ptp].empty? ? 0 : @@doctor_rating_values["residing_distance_from_puttaparthi"][user[:residing_disance_from_ptp]]
    doctors_rating_hash['referred_by_existing_doctor_rating'] = user[:doctors_referral].to_i==1 ? @@doctor_rating_values["referred_by_existing_doctor"][true] : @@doctor_rating_values["referred_by_existing_doctor"][false]
    total_rating = 0
    doctors_rating_hash.each_pair {|e_key,e_val| total_rating = total_rating + e_val}
    doctors_rating_hash['total_rating'] = total_rating
    doctors_rating_hash
  end
  
  def calculate_doctors_qualification_rating(user_qualification)
    
  end
  
  def calculate_qualification_from_which_institution_rating(institution_name)
    institution_name=~/aims/ ? @@doctor_rating_values["qualification_from_which_institution"]['aims'] : @@doctor_rating_values["qualification_from_which_institution"]['other_than_aims']
  end
  
end