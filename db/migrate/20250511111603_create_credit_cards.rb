class CreateCreditCards < ActiveRecord::Migration[7.0]
  def change
    create_table :credit_cards do |t|
      t.string :name_on_card, null: false
      t.string :card_number, null: false
      t.integer :expiration_month, null: false
      t.integer :expiration_year, null:false
      # CVVはDBに保存しない
      t.references :checkout, null:false, foreign_key: true


      t.timestamps
    end
  end
end