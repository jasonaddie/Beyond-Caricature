class TranslatePubLangs < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        PublicationLanguage.create_translation_table!({
          :language => :string
        }, {
          :migrate_data => true,
          :remove_source_columns => true
        })
      end

      dir.down do
        PublicationLanguage.drop_translation_table! :migrate_data => true
      end
    end
  end
end
