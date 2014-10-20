class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets, :options=>"TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :filename, :string
      t.column :content_type, :string
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
      t.column :parent_id, :integer
      t.column :thumbnail, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
