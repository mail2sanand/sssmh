class ChangeYearsOfExpType < ActiveRecord::Migration
  def self.up
    change_table :user_professional_details do |t|
      t.change :years_of_exp, :string, :limit => 50 
    end
  end

  def self.down
    change_table :user_professional_details do |t|
      t.change :years_of_exp, :integer 
    end
  end
  
end
