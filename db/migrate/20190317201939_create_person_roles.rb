class CreatePersonRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :person_roles do |t|
      t.references :person, index: true
      t.references :person_roleable, polymorphic: true, index: {name: :idx_person_roleable}

      t.timestamps
    end
  end
end
