class DatePublishWithTime < ActiveRecord::Migration[5.2]
  def change

    # remove indexes
    remove_index :highlight_translations, :date_publish
    remove_index :illustration_translations, :date_publish
    remove_index :issues, :date_publish
    remove_index :news_translations, :date_publish
    remove_index :person_translations, :date_publish
    remove_index :publication_translations, :date_publish
    remove_index :research_translations, :date_publish

    # rename existing date_publish
    rename_column :highlight_translations, :date_publish, :date_publish_old
    rename_column :illustration_translations, :date_publish, :date_publish_old
    rename_column :issues, :date_publish, :date_publish_old
    rename_column :news_translations, :date_publish, :date_publish_old
    rename_column :person_translations, :date_publish, :date_publish_old
    rename_column :publication_translations, :date_publish, :date_publish_old
    rename_column :research_translations, :date_publish, :date_publish_old

    # create new field with index
    add_column :highlight_translations, :published_at, :datetime, default: nil, index: true
    add_column :illustration_translations, :published_at, :datetime, default: nil, index: true
    add_column :issues, :published_at, :datetime, default: nil, index: true
    add_column :news_translations, :published_at, :datetime, default: nil, index: true
    add_column :person_translations, :published_at, :datetime, default: nil, index: true
    add_column :publication_translations, :published_at, :datetime, default: nil, index: true
    add_column :research_translations, :published_at, :datetime, default: nil, index: true

    # populate data
    puts "- updating data"
    reversible do |dir|
      dir.up do
        locales = I18n.available_locales
        [Highlight, Illustration, News, Person, Publication, Research].each do |model|
          puts "- #{model}"

          model.all.each do |record|
            locales.each do |locale|
              I18n.locale = locale.to_sym

              locale_record = record.translations.select{|x| x.locale == locale}.first
              if locale_record.present?
                record.published_at = locale_record.date_publish_old

                # skip the callback to set the published at date
                record.skip_published_at_callback(true)

                # vaidation required for public fields can cause saving to fail so skip validation
                record.save(:validate => false)
              end
            end
          end
        end

        Issue.all.each do |record|
          record.published_at = record.date_publish_old
          # skip the callback to set the published at date
          record.skip_published_at_callback(true)
          record.save(:validate => false)
        end
      end

      dir.down do
        # do nothing
      end
    end



  end
end
