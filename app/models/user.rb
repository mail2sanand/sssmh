require "digest"
require 'digest/sha1'
class User < ActiveRecord::Base
  
#  include CacheExpirationHelper
  
  has_one :user_professional_detail
  has_many :user_schedules, :dependent => :destroy
  has_many :schedules, :through => :user_schedules
  has_one :user_rating, :dependent => :destroy
  
  named_scope :to_be_approved, :conditions=>{:approved => false}

  named_scope :approved, 
              :conditions=>["approved = 1 and login <> 'admin'"]
  
  named_scope(:non_volunteered_docs, 
              lambda { |schedule_id| {
                :select => ("distinct(users.user_id),full_name,photo,email,age,gender,contact_mob_no,upd.specialization,users.approved,sp.name as specializations"),
                :joins => ("left outer join user_professional_details upd on upd.user_id = users.user_id 
                            left outer join user_schedules us on users.user_id = us.user_id and us.schedule_id <> #{schedule_id}
                            left outer join schedules s on s.id = us.schedule_id
                            left outer join specializations sp on upd.specialization = sp.id"),
                :conditions => ["users.user_id not in (select distinct(user_schedules.user_id) from user_schedules where schedule_id = #{schedule_id}) and users.user_role <> 1"]
              } }
           )

  set_primary_key :user_id
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password,:photo_content_type,:new_password,:confirm_new_password
  
  validates_presence_of     :login, :email,:age,:contact_mob_no,:address
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?

  validates_length_of       :new_password, :within => 4..40, :if => :new_password_required?
  validates_presence_of     :new_password_confirmation,      :if => :new_password_required?
  validates_confirmation_of :new_password,                   :if => :new_password_required?
  
  validates_length_of       :login,    :within => 3..40, :if => :login_not_blank? 
  validates_length_of       :email,    :within => 3..100, :if => :email_not_blank?

  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of :photo_content_type,
                      :with => /^IMAGE/,
                      :message => "-- you can only upload pictures",
                      :if => :photo_uploaded?

  before_save :encrypt_password
  
  #delete_user_caches can be found in the CacheExpirationHelper module
#  after_save :delete_user_caches
#  after_update :delete_user_caches
#  after_destroy :delete_user_caches
=begin  
  def self.get_all_approved_users(force = false)
    
    Rails.cache.fetch('approved_users_except_admin',:force => force) do
      self.approved
#      User.find(:all,
#                :conditions=>["approved = 1 and login <> 'admin'"])
    end
#      { User.approved_members }
    #self.approved
  end
=end

  def login_not_blank?
    !login.empty?
  end
  
  def email_not_blank?
    !email.blank?
  end

  def self.get_users_to_be_approved
    find(:all,:conditions=>["approved = ?",false])
  end

  def approved!
    self.approved = true
  end

  def is_approved?
    self.approved
  end

  def uploaded_picture=(picture_field)
#    self.photo = base_part_of(picture_field.original_filename)
    if picture_field
      self.photo_content_type = picture_field.content_type.chomp.upcase 
      self.photo = picture_field.read
    end
#    puts "self.photo Size : #{self.photo.length/1024}"
  end

  #This method is used to get the file_name in the above method.
  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '' )
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end
  
  def verify_and_update_passwords(password_list)
    error_message = ""
    if self.crypted_password == self.class.encrypt(password_list.first, salt)
      if password_list.second == password_list.third
        self.update_attribute("crypted_password",self.class.encrypt(password_list.second, salt))
      else
        error_message += "The New Password doesn't seem to match with the New Confirmed Password. Please check it."
      end
    else
      error_message += "Please enter the Present Password in the Current Password field"
    end
    error_message
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def self.invite_user_for_schedule(user_id,schedule_id)
    begin
      user = self.find(user_id.to_i)
      if UserSchedule.find_by_user_id_and_schedule_id(user_id,schedule_id).nil?
        UserSchedule.create({ :user_id => user.user_id,
                              :schedule_id => schedule_id,
                              :invited => true,
                              :volunteered => false,
                              :approved => 1})
      else
        return false
      end
    rescue
      raise
    end
    return user
  end

  def self.approve_reject_user_for_schedule(user_id,schedule_id,approve_reject)
    begin
      user = self.find(user_id.to_i)
      user_schedule = UserSchedule.find_by_user_id_and_schedule_id(user_id,schedule_id)
      approved_value = (approve_reject == 'approve' ? 1 : -1)
      user_schedule.update_attribute('approved', approved_value)
    rescue
      return false
    end
    return user
  end

  def is_invited_for_schedule?(schedule_id)
    self.volunteer_type(schedule_id) == "invited" 
  end

  def is_invited_and_volunteered_for_schedule?(schedule_id)
    UserSchedule.find_by_user_id_and_schedule_id_and_invited_and_volunteered(self.user_id,schedule_id,true,true).nil?
  end
  
  def volunteer_type_and_status(schedule_id)
    user_schedule = UserSchedule.find_by_user_id_and_schedule_id(self.user_id,schedule_id)
    if user_schedule
      user_invited = user_schedule.invited
      user_volunteered = user_schedule.volunteered
      user_schedule_satus = user_schedule.approved
      
      if user_invited.nil?
        return "volunteered",user_schedule_satus
      elsif user_invited == true and user_volunteered == 1
        return "Invited and Volunteered",user_schedule_satus
      elsif user_invited == true and user_volunteered == -1
        return "Invited and Rejected",user_schedule_satus
      else
        return "Invited and Waiting",user_schedule_satus
      end
    else
      return false, false
    end
  end
  
  def self.rating(user_id)
    max_user_rating = UserRating.max_user_rating
    userrating = UserRating.find_by_user_id(user_id)
    if userrating
      user_rating = userrating.total_rating 
      return (user_rating * 100)/max_user_rating
    else
      return  0
    end
  end

  def rating
    max_user_rating = UserRating.max_user_rating
    userrating = UserRating.find_by_user_id(self.user_id)
    if userrating
      user_rating = userrating.total_rating 
      return (user_rating * 100)/max_user_rating
    else
      return  0
    end
  end


  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def new_password_required?
      !new_password.blank?
    end

    def photo_uploaded?
      !self.photo_content_type.blank?
    end
end
