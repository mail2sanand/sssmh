require 'migration_helpers'

class CreateUserRatings < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :user_ratings do |t|
      t.column :user_id, :integer, :belongs_to => :user
      t.column :doctors_qualification_rating, :integer
      t.column :qualification_from_which_institution_rating, :integer
      t.column :years_of_experience_rating, :integer
      t.column :type_of_practice_rating, :integer
      t.column :research_interest_rating, :integer
      t.column :voluntary_medical_activity_in_24_months_rating, :integer
      t.column :own_a_hospital_rating, :integer
      t.column :residing_distance_from_puttaparthi_rating, :integer
      t.column :referred_by_existing_doctor_rating, :integer
      t.column :total_rating, :integer
      t.column :admin_override_rating, :integer
      t.timestamps
    end
    
    foreign_key(:user_ratings, :user_id, :users, "user_id")
    
  end

  def self.down
    drop_table :user_ratings
  end
  
end
