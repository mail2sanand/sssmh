require 'migration_helpers'

class CreateSchedules < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :schedules,:options => "TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :programme_name, :string
      t.column :location_id, :string  #, :belongs_to => :location
      t.column :other_locations, :string
      t.column :specializations, :string
      t.timestamps
    end

    #This is commented because all locations are stored in a string format   
#    foreign_key(:schedules, :location_id, :locations)
  end

  def self.down
    drop_table :schedules
  end
end
