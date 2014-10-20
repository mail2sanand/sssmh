class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations,:options => "TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :location_name, :string, :null => false
      t.column :location_address, :string
      t.column :day_of_the_month, :integer
      t.column :location_map, :binary, :limit=>3.megabytes
      t.timestamps
    end
    Location.create({:location_name => 'Marakunta Palli',:day_of_the_month => 1})
    Location.create({:location_name => 'Byrapuram',:day_of_the_month => 2})
    Location.create({:location_name => 'Kotala Palli',:day_of_the_month => 3})
    Location.create({:location_name => 'Rachuvarapalli',:day_of_the_month => 4})
    Location.create({:location_name => 'Cherla Palli',:day_of_the_month => 5})
    Location.create({:location_name => 'Kondakamrala',:day_of_the_month => 6})
    Location.create({:location_name => 'Chowkunta Palli',:day_of_the_month => 7})
    Location.create({:location_name => 'Vaskarakunta',:day_of_the_month => 8})
    Location.create({:location_name => 'Veldurthy',:day_of_the_month => 9})
    Location.create({:location_name => 'Mylasamudram',:day_of_the_month => 10})
    Location.create({:location_name => 'Marala',:day_of_the_month => 11})
    Location.create({:location_name => 'Chandrayana Palli',:day_of_the_month => 12})
    Location.create({:location_name => 'Others'})
  end

  def self.down
    drop_table :locations
  end
end
