class AddInvitedToUserSchedules < ActiveRecord::Migration
  def self.up
    add_column(:user_schedules, :invited, :boolean)
    add_column(:user_schedules, :volunteered, :integer, {:default => 1})
  end

  def self.down
    remove_column(:user_schedules, :invited)
    remove_column(:user_schedules, :volunteered)
  end
end
