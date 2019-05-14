class AddCropAlignmentFields < ActiveRecord::Migration[5.2]
  def change
    add_column :highlights, :crop_alignment, :string, default: 'c'
    add_column :illustrations, :crop_alignment, :string, default: 'c'
    add_column :issues, :crop_alignment, :string, default: 'c'
    add_column :news, :crop_alignment, :string, default: 'c'
    add_column :people, :crop_alignment, :string, default: 'c'
    add_column :publications, :crop_alignment, :string, default: 'c'
    add_column :researches, :crop_alignment, :string, default: 'c'
  end
end
