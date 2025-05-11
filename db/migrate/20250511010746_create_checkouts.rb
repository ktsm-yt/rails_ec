class CreateCheckouts < ActiveRecord::Migration[7.0]
  def change
    create_table :checkouts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :username, null: false
      t.string :email, null: false
      t.string :address1, null: false
      t.string :address2
      t.references :country, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.string :zip, null: false
      t.boolean :shipping_same_as_billing
      t.boolean :save_info_for_next_time
    
      t.timestamps
    end
  end
end