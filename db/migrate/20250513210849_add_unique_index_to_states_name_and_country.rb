class AddUniqueIndexToStatesNameAndCountry < ActiveRecord::Migration[7.0]
  def change
    add_index :states, [:country_id, :name], unique: true
  end
end
