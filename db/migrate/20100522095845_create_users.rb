class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :primary_key => :user_id, :force => true,:options => "TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :login,                     :string, :limit => 30,:null => false
      t.column :email,                     :string,:null => false
      t.column :crypted_password,          :string, :limit => 40,:null => false
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.boolean :gender,:null => false
      t.integer :age, :limit => 100,:null => false
      t.string :full_name,:null => false
      t.string :address
      t.boolean :sss_org_association
      t.string :sss_org_association_details
      t.string :contact_mob_no,:null => false
      t.string :contact_home_no
      t.string :possible_freq_of_visit
      t.string :possible_duration_of_visit
      t.binary :photo, :limit=>3.megabytes
      t.boolean :volunteer_activity
      t.string :volunteer_activity_details
      t.string :residing_disance_from_ptp
      t.boolean :doctors_referral
      t.string :comments
      t.boolean :approved,:default=>false
      t.timestamps
      t.datetime :deleted_at
    end

    User.new(:login => "admin",
                :password=>"keepitsafe",
                :password_confirmation=>"keepitsafe",
                :email=>"mail2sanand_83@yahoo.co.in",
                :gender=>1,
                :age=>26,
                :full_name=>"SSSMH Admin",
                :contact_mob_no=>"9500079694",
                :approved => true).save!
  end

  def self.down
    drop_table :users
  end
end
