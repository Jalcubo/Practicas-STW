class CreateVisit < ActiveRecord::Migration
  def up
    create_table :visits do |t|
      t.string :ip
	  t.string :country
	  t.string :shortened_url_id
    end
  end
	
  def down
    drop_table :visits
  end
  
  
end
