class RemoveOldFields < ActiveRecord::Migration[5.2]
  def up
    drop_table :illustrators
    drop_table :illustrator_translations

    remove_index :related_items, :illustrator_id
    remove_column :related_items, :illustrator_id
  end

  def down
    puts "do nothing"
  end
end
