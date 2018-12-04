class UpdatePubFields < ActiveRecord::Migration[5.2]
  def up
    remove_index :publications, :year_publication_start
    remove_index :publications, :year_publication_end
    remove_index :publications, :date_publication

    remove_column :publications, :year_publication_start
    remove_column :publications, :year_publication_end
    remove_column :publications, :date_publication

    add_column :publications, :year, :integer
    add_index :publications, :year

  end

  def down
    add_column :publications, :year_publication_start, :integer
    add_column :publications, :year_publication_end, :integer
    add_column :publications, :date_publication, :date

    add_index :publications, :year_publication_start
    add_index :publications, :year_publication_end
    add_index :publications, :date_publication

    remove_index :publications, :year
    remove_column :publications, :year
  end
end
