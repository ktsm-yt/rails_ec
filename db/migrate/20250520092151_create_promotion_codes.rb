class CreatePromotionCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :promotion_codes do |t|
      t.string :code, null: false
      t.integer :discount_amount, null: false
      t.boolean :active, null:false, default: true
      t.datetime :expires_at
      t.boolean :used, null: false, default: false

      t.timestamps
    end

    add_index :promotion_codes, :code, unique: true
  end
end
