require 'migration_helpers'

class CreateUserProfessionalDetails < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :user_professional_details, :primary_key => :user_professional_detail_id,:options => "TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer :user_id, {:belongs_to => :users}
      t.string :designation, :null => false
      t.string :specialization, :null => false
      t.string :qualification, :null => false
      t.string :institution_name, :null => false
      t.string :type_of_practice, :null => false
      t.string :medical_registration_number, :null => false
      t.string :reporting_authority_and_designation
      t.string :working_dept
      t.integer :years_of_exp, :null => false
      t.boolean :research_interest
      t.string :research_details
      t.string :papers_published
      t.boolean :special_training
      t.string :special_training_details
      t.boolean :special_conf_attended
      t.string :special_conf_attended_details
      t.boolean :own_clinic_or_hospital
      t.string :treatments_offered
      t.string :equipments_available
      t.integer :beds_count
    end
    
    foreign_key(:user_professional_details, :user_id, :users, "user_id")
    
    UserProfessionalDetail.create({ :user_id => User.find_by_login('admin').user_id,
                                    :designation => 'admin',
                                    :specialization => 'admin',
                                    :qualification => 'admin',
                                    :institution_name => 'admin',
                                    :type_of_practice => 'admin',
                                    :medical_registration_number => 'admin',
                                    :years_of_exp => 20})

  end

  def self.down
    drop_table :user_professional_details
  end
end
