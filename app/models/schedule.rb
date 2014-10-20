class Schedule < ActiveRecord::Base
  has_many :user_schedules, :dependent => :destroy
  has_many :users, :through => :user_schedules
  
  validates_presence_of :programme_name,:start_date,:end_date,:specializations
  
  def get_specializations
#    all_specializations_array = self.specializations.gsub(/"|\[|\]/,"").split(", ").map(&:to_i)
    all_specializations_array = self.specializations.gsub(/"|\[|\]/,"")
    Specialization.find_by_sql("select name from specializations where id in (#{all_specializations_array})").map(&:name).join("<br>")
  end
  
end
