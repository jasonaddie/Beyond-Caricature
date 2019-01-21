class CreateIllustrationAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :illustration_annotations do |t|
      t.belongs_to :illustration, index: true
      t.integer :sort, limit: 1, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        IllustrationAnnotation.create_translation_table! :annotation => {type: :string, limit: 1000}
      end

      dir.down do
        IllustrationAnnotation.drop_translation_table!
      end
    end

    add_index :illustration_annotations, :sort

  end
end
