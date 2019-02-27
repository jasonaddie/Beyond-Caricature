class AddSlideshowTranslations < ActiveRecord::Migration[5.2]
  def change

    reversible do |dir|
      dir.up do
        Slideshow.create_translation_table! :caption => :string
      end

      dir.down do
        Slideshow.drop_translation_table!
      end
    end
  end
end
