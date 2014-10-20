require 'migration_helpers'

class CreateUserSchedules < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :user_schedules,:options => "TYPE=InnoDB DEFAULT CHARSET=utf8"  do |t|
      t.column :user_id, :integer, :belongs_to => :user
      t.column :schedule_id, :integer, :belongs_to => :schedule
      t.timestamps
    end
    
    foreign_key(:user_schedules, :user_id, :users, "user_id")
    foreign_key(:user_schedules, :schedule_id, :schedules)
  end

  def self.down
    drop_table :user_schedules
  end
end
