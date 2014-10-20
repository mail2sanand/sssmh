require 'migration_helpers'

class CreateNewsletters < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :newsletters do |t|
      t.column :name, :string
      t.column :newsletter_path, :string
      t.column :year, :string
      t.column :month, :string
      t.column :volume, :string
      t.column :issue, :string
      t.timestamps
    end
    
    # foreign_key(:user_ratings, :user_id, :users, "user_id")
    
  end

  def self.down
    drop_table :newsletters 
  end
  
end
