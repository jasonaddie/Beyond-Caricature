class RemoveEnumDefaultValues < ActiveRecord::Migration[5.2]
  def up
    change_column_default :related_items, :related_item_type, nil
    change_column_default :publications, :publication_type, nil
  end

  def down
    change_column_default :related_items, :related_item_type, 0
    change_column_default :publications, :publication_type, 0
  end
end
