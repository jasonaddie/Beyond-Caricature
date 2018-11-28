class AddLocaleToVersioning < ActiveRecord::Migration[5.2]
  def change
    change_table :versions do |t|
      t.string :locale
    end
  end
end
