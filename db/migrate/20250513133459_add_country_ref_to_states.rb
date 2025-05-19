class AddCountryRefToStates < ActiveRecord::Migration[7.0]
  def change
    add_reference :states, :country, null: false, foreign_key: true
  end
end
