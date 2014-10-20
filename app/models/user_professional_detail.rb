class UserProfessionalDetail < ActiveRecord::Base
include ApplicationHelper

  belongs_to :user
  
  #Paper Clip functionality
  has_attached_file :certificate,
#                    :styles => {
#                      :thumb=> "100x100#",
#                      :small  => "150x150>"
#                    },
                    :url => "/:class/:attachment/:id/:style_:basename.:extension",
                    :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension"

  set_primary_key :user_professional_detail_id
  
  attr_accessor :certificate_type, :doctor_certificate, :doctor_certificate_size,:edit_profile
  
  validates_presence_of :designation, :specialization, :qualification, :institution_name, :medical_registration_number, :years_of_exp
  
  validates_presence_of :doctor_certificate,
                        :message => " : upload your relevant certificate in PDF format (< 2 MB)",
                        :if => :not_edit?
    
  validates_format_of :certificate_type,
                      :with => /^(IMAGE)|(APPLICATION\/PDF)/,
                      :message => "should be in a any image or PDF format",
                      :if => :certificate_upload?
  
  def not_edit?
    self.edit_profile ? false : true
  end
                        
  def validate
    if certificate_upload? and self.doctor_certificate_size > 2
      errors.add(:doctor_certificate_size,"should be less than 2 MB")
    end
  end

  def uploaded_certificate=(relavant_certificate)
#    self.photo = base_part_of(picture_field.original_filename)

    self.certificate = relavant_certificate

    self.certificate_type = relavant_certificate.content_type.chomp.upcase
    self.doctor_certificate = true
    self.doctor_certificate_size = bytesToMeg(relavant_certificate.size)
  end

  def certificate_upload?
    option = true
    if self.edit_profile
      option = (self.certificate_type.nil? ? false : true)
    else
      option = (!self.certificate_type.blank?)
    end
#    puts "Final option : #{option}"
#    puts "-----------------"
    option
  end
  
  def get_specialization
    Specialization.find(self.specialization.to_i).name
  end

end
