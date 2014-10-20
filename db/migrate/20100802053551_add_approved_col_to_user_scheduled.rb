class AddApprovedColToUserScheduled < ActiveRecord::Migration
  def self.up
    add_column(:user_schedules, :approved, :integer,:default => 0)
  end

  def self.down
    remove_column(:user_schedules, :approved)
  end
end
