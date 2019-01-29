class AddAnnotationXy < ActiveRecord::Migration[5.2]
  def change
    add_column :illustration_annotations, :x, :decimal, precision: 5, scale: 4
    add_column :illustration_annotations, :y, :decimal, precision: 5, scale: 4
  end
end
