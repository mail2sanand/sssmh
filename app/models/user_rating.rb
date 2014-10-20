class UserRating < ActiveRecord::Base
  belongs_to :user

  def self.max_user_rating
   @@doctor_rating_values = YAML.load(File.open("#{RAILS_ROOT}/config/doc_rating_config.yml"))
   @@doctor_rating_values['doctors_qualification']['max']+@@doctor_rating_values['qualification_from_which_institution']['max']+
    @@doctor_rating_values['years_of_experience']['max']+@@doctor_rating_values['type_of_practice']['max']+
    @@doctor_rating_values['research_interest']['max']+@@doctor_rating_values['voluntary_medical_activity_in_24_months']['max']+
    @@doctor_rating_values['own_a_hospital']['max']+@@doctor_rating_values['residing_distance_from_puttaparthi']['max']+
    @@doctor_rating_values['referred_by_existing_doctor']['max']
  end
end
