class MoveIsPublicFields2 < ActiveRecord::Migration[5.2]
  def up
    # reserach
    add_column :research_translations, :is_public, :boolean, default: false
    add_column :research_translations, :date_publish, :date
    add_index :research_translations, :is_public
    add_index :research_translations, :date_publish

    remove_index :researches, :is_public
    remove_index :researches, :date_publish
    remove_column :researches, :is_public
    remove_column :researches, :date_publish

    # illustrator
    add_column :illustrator_translations, :is_public, :boolean, default: false
    add_column :illustrator_translations, :date_publish, :date
    add_index :illustrator_translations, :is_public
    add_index :illustrator_translations, :date_publish

    remove_index :illustrators, :is_public
    remove_column :illustrators, :is_public

    # illustration
    add_column :illustration_translations, :is_public, :boolean, default: false
    add_column :illustration_translations, :date_publish, :date
    add_index :illustration_translations, :is_public
    add_index :illustration_translations, :date_publish

    remove_index :illustrations, :is_public
    remove_index :illustrations, :date_publish
    remove_column :illustrations, :is_public
    remove_column :illustrations, :date_publish

    # publication
    add_column :publication_translations, :is_public, :boolean, default: false
    add_column :publication_translations, :date_publish, :date
    add_index :publication_translations, :is_public
    add_index :publication_translations, :date_publish

    remove_index :publications, :is_public
    remove_index :publications, :date_publish
    remove_column :publications, :is_public
    remove_column :publications, :date_publish

  end

  def down
    # research
    add_column :researches, :is_public, :boolean, default: false
    add_column :researches, :date_publish, :date
    add_index :researches, :is_public
    add_index :researches, :date_publish

    remove_index :research_translations, :is_public
    remove_index :research_translations, :date_publish
    remove_column :research_translations, :is_public
    remove_column :research_translations, :date_publish

    # illustrator
    add_column :illustrators, :is_public, :boolean, default: false
    add_index :illustrators, :is_public

    remove_index :illustrator_translations, :is_public
    remove_index :illustrator_translations, :date_publish
    remove_column :illustrator_translations, :is_public
    remove_column :illustrator_translations, :date_publish

    # illustration
    add_column :illustrations, :is_public, :boolean, default: false
    add_column :illustrations, :date_publish, :date
    add_index :illustrations, :is_public
    add_index :illustrations, :date_publish

    remove_index :illustration_translations, :is_public
    remove_index :illustration_translations, :date_publish
    remove_column :illustration_translations, :is_public
    remove_column :illustration_translations, :date_publish

    # publication
    add_column :publications, :is_public, :boolean, default: false
    add_column :publications, :date_publish, :date
    add_index :publications, :is_public
    add_index :publications, :date_publish

    remove_index :research_translations, :is_public
    remove_index :research_translations, :date_publish
    remove_column :research_translations, :is_public
    remove_column :research_translations, :date_publish

  end
end
