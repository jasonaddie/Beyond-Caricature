class AddPeopleReference < ActiveRecord::Migration[5.2]
  def change
    add_reference :illustrations, :person, index: true
    add_reference :related_items, :person, index: true
  end
end
