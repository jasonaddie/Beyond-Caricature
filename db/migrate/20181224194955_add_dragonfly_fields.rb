class AddDragonflyFields < ActiveRecord::Migration[5.2]
  def change
    add_column :highlights, :cover_image_uid,  :string
    add_column :illustrations, :image_uid,  :string
    add_column :illustrators, :image_uid,  :string
    add_column :issues, :cover_image_uid,  :string
    add_column :issues, :scanned_file_uid,  :string
    add_column :news, :cover_image_uid,  :string
    add_column :publications, :cover_image_uid,  :string
    add_column :publications, :scanned_file_uid,  :string
    add_column :researches, :cover_image_uid,  :string
  end
end
