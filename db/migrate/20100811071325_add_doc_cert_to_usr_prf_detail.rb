class AddDocCertToUsrPrfDetail < ActiveRecord::Migration
  def self.up
    add_column :user_professional_details, :certificate_file_name, :string # Original filename
    add_column :user_professional_details, :certificate_content_type, :string # Mime type
    add_column :user_professional_details, :certificate_file_size, :integer # File size in bytes
  end

  def self.down
    remove_column :user_professional_details, :certificate_file_name
    remove_column :user_professional_details, :certificate_content_type
    remove_column :user_professional_details, :certificate_file_size
  end
  
end
