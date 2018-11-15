class CreateIllustrationPublications < ActiveRecord::Migration[5.2]
  def change
    create_table :illustration_publications do |t|
      t.references :illustration
      t.references :publication
      t.integer :page_number_start
      t.integer :page_number_end
      t.boolean :is_public, default: false

      t.timestamps
    end

    add_index :illustration_publications, :is_public
  end
end
