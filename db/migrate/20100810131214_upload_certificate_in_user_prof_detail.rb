class UploadCertificateInUserProfDetail < ActiveRecord::Migration
  def self.up
#    add_column(:user_professional_details, :qualification_certificate_1, :string, :default => nil, :null => false)
    change_table :user_professional_details do |t|
      t.change :specialization, :string, :limit => 150
      t.change :qualification, :string, :limit => 100
      t.change :type_of_practice, :string, :limit => 100
      t.change :medical_registration_number, :string, :limit => 150
    end
  end

  def self.down
    change_table :user_professional_details do |t|
      t.change :specialization, :string
      t.change :qualification, :string
      t.change :type_of_practice, :string
      t.change :medical_registration_number, :string
#      t.remove :qualification_certificate_1
    end
  end
end
