class CreateSpecializations < ActiveRecord::Migration
  def self.up
    create_table :specializations,:options=>"TYPE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :name, :string,:null => false
      t.column :description, :string
      t.column :specialization_type,:string
      t.timestamps
    end
    
    Specialization.create({:name => "Radiology",:specialization_type=>"M"})
    Specialization.create({:name => "Medicine",:specialization_type=>"M"})
    Specialization.create({:name => "Surgery",:specialization_type=>"M"})
    Specialization.create({:name => "Orthopedics",:specialization_type=>"M"})
    Specialization.create({:name => "Obstetrics & Gynaecology",:specialization_type=>"M"})
    Specialization.create({:name => "E.N.T",:specialization_type=>"M"})
    Specialization.create({:name => "Dentistry ",:specialization_type=>"M"})
    Specialization.create({:name => "Ophthalmology",:specialization_type=>"M"})
    Specialization.create({:name => "Paediatrics",:specialization_type=>"M"})
    Specialization.create({:name => "Dermatology",:specialization_type=>"M"})
    Specialization.create({:name => "Psychiatry",:specialization_type=>"M"})
    Specialization.create({:name => "Nephrology",:specialization_type=>"M"})
    Specialization.create({:name => "Endocrinology",:specialization_type=>"M"})

    Specialization.create({:name => "Urology",:specialization_type=>"o"})
    Specialization.create({:name => "Cardiology",:specialization_type=>"o"})
    Specialization.create({:name => "Cardio-Thoracic Surgery",:specialization_type=>"o"})
    Specialization.create({:name => "Neurology",:specialization_type=>"o"})
    
  end

  def self.down
    drop_table :specializations
  end
end
