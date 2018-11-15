class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues do |t|
      t.references :publication
      t.string :issue_number
      t.date :date_publication
      t.boolean :is_public, default: false
      t.date :date_publish

      t.timestamps
    end
    add_index :issues, :date_publication
    add_index :issues, :is_public
    add_index :issues, :date_publish
  end
end
