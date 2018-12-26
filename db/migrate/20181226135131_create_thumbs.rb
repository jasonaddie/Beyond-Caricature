class CreateThumbs < ActiveRecord::Migration[5.2]
  def change
    create_table :thumbs do |t|
      t.string :uid
      t.string :job

      t.timestamps
    end

    add_index :thumbs, :uid
    add_index :thumbs, :job
  end
end
