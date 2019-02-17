class RecordScannedFileSize < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :scanned_file_size, :integer
    add_column :publications, :scanned_file_size, :integer
  end
end
