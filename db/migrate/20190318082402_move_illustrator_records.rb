class MoveIllustratorRecords < ActiveRecord::Migration[5.2]
  def up
    # move all illustrators to people
    # andupdate illustration and related item references

    Illustrator.all.each do |old|
      p = Person.new(date_birth: old.date_birth, date_death: old.date_death, slug: old.slug)
      p.name_translations = old.name_translations
      p.bio_translations = old.bio_translations
      p.is_public_translations = old.is_public_translations
      p.date_publish_translations = old.date_publish_translations
      p.slug_translations = old.slug_translations
      p.save

      Illustration.where(illustrator_id: old.id).each do |illustration|
        illustration.person_role.create(person_id: p.id, role: :illustrator)
      end
      RelatedItem.where(illustrator_id: old.id).each do |item|
        item.person_id = p.id
        item.save
      end

    end

  end

  def down
    Person.destroy_all
  end
end
