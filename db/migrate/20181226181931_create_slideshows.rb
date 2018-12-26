class CreateSlideshows < ActiveRecord::Migration[5.2]
  def change
    create_table :slideshows do |t|
      t.integer :sort, default: 0
      t.string :image_uid
      t.references :imageable, polymorphic: true, index:true

      t.timestamps
    end

    add_index :slideshows, :sort
  end
end
