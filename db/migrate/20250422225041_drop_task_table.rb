class DropTaskTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :tasks
  end
end
