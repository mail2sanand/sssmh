class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles,:options => "TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :role,:string,:null=>false
      t.column :role_description,:string
      t.timestamps
    end

    admin_role = Role.create(:role => "admin",:role_description => "Can Have All the Access to everbody's information (Except User's Passwords)")
    general_role = Role.create(:role => "general",:role_description => "Normal user")

    add_column :users, :user_role, :integer, :belongs_to => :roles, :null => false, :default => general_role.id
    User.find_by_login("admin").update_attribute("user_role",admin_role.id)

    volunteer_role = Role.create(:role => "volunteer",:role_description => "Seva Member")
    director_role = Role.create(:role => "director",:role_description => "Equal to Admin Role")
    doctor_role = Role.create(:role => "doctor",:role_description => "Doctor")

  end

  def self.down
    drop_table :roles
    remove_column :users, :user_role
  end
end
