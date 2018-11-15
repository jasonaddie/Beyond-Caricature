class CreateIllustrationTags < ActiveRecord::Migration[5.2]
  def change
    create_table :illustration_tags do |t|
      t.belongs_to :illustration, index: true
      t.belongs_to :tag, index: true

      t.timestamps
    end
  end
end
