class CreateRelatedItems < ActiveRecord::Migration[5.2]
  def change
    create_table :related_items do |t|
      t.integer :related_item_type, default: 0
      t.integer :news_itemable_id
      t.string :news_itemable_type
      t.references :publication, null: true
      t.references :illustration, null: true
      t.references :illustrator, null: true
      t.references :issue, null: true

      t.timestamps
    end

    add_index :related_items, :related_item_type
    add_index :related_items, [:news_itemable_id, :news_itemable_type], name: :idx_related_items_news
  end
end
