# == Schema Information
#
# Table name: person_roles
#
#  id                   :bigint(8)        not null, primary key
#  person_id            :bigint(8)
#  person_roleable_type :string
#  person_roleable_id   :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  role_old             :integer
#  role_id              :bigint(8)
#

class PersonRole < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :person, -> { published }
  belongs_to :person_roleable, :polymorphic => true
  belongs_to :role

  #################
  ## VALIDATION ##
  #################

  #################
  ## SCOPES ##
  #################
  # get all records that are for illustrators
  def self.illustrators
    where(role_id: Role.illustrators.pluck(:id))
  end

  # group the person records by the role
  def self.group_people_by_role
    groups = {}
    roles = Role.where(id: self.pluck(:role_id).uniq).sort_name_asc

    if roles.present?
      roles.each do |role|
        groups[role.name] = self.where(role_id: role.id).includes(:person).order('person_translations.name asc')
      end
    end

    return groups
  end


  # return a hash where the key is the role and the values are:
  #  - total - total number of published records for this role
  #  - latest_records - the latest records limited by the limit argument
  def self.group_published_record_by_role(limit=6)
    groups = {}
    roles = Role.where(id: self.pluck(:role_id).uniq).sort_name_asc

    if roles.present?
      # if role
      # - illustrator - then get all published illustrations
      # - else, get all published publications
      #   - role can be assigned to publication or publication editors
      #     so if publication editor, go up a level and get publication
      roles.each do |role|
        person_roles = self.where(role_id: role.id)
        record_ids = {
          publications: person_roles.where(person_roleable_type: 'Publication').pluck(:person_roleable_id).uniq,
          pub_editors: person_roles.where(person_roleable_type: 'PublicationEditor').pluck(:person_roleable_id).uniq,
          publication_ids: [],
          illustration_ids: person_roles.where(person_roleable_type: 'Illustration').pluck(:person_roleable_id).uniq
        }
        if record_ids[:publications].present?
          # get publication ids
          record_ids[:publication_ids] << record_ids[:publications]
        end
        if record_ids[:pub_editors].present?
          # get publication ids
          record_ids[:publication_ids] << PublicationEditor.where(id: record_ids[:pub_editors]).pluck(:publication_id).uniq
        end
        # make sure we only have unique ids
        record_ids[:publication_ids] = record_ids[:publication_ids].flatten.uniq

        published_record_ids = {publications: nil, illustrations: nil}
        if record_ids[:publication_ids].present?
          published_record_ids[:publications] = Publication.published.where(id: record_ids[:publication_ids]).pluck(:id)
        end
        if record_ids[:illustration_ids].present?
          published_record_ids[:illustrations] = Illustration.published.where(id: record_ids[:illustration_ids]).pluck(:id)
        end



        if published_record_ids[:publications].present? || published_record_ids[:illustrations].present?
          records = []

          if published_record_ids[:publications].present?
            records << Publication.published.where(id: published_record_ids[:publications]).sort_published_desc.limit(limit)
          end
          if published_record_ids[:illustrations].present?
            records << Illustration.published.where(id: published_record_ids[:illustrations]).sort_published_desc.limit(limit)
          end
          records.flatten!
          records.compact!

          groups[role.name] = {role_id: role.id,
                                total: {publication: (published_record_ids[:publications].present? ? published_record_ids[:publications].length : 0),
                                        illustration: (published_record_ids[:illustrations].present? ? published_record_ids[:illustrations].length : 0)},
                                latest_records: records.sort_by{|x| x.published_at}.reverse[0..(limit-1)]}
        end
      end
    end

    return groups
  end

  # get list of unique roles
  def self.unique_roles
    roles = []
    records = self.all
    uniq_roles = Role.where(id: records.map{|x| x.role_id}.uniq.reject(&:nil?)).sort_name_asc

    if uniq_roles.present?
      uniq_roles.sort.each do |role|
        roles << {
          name: role.name,
          count: records.select{|x| x.role_id == role.id}.count
        }
      end
    end

    return roles
  end

  #################
  ## METHODS ##
  #################
  # translated name of the role
  def role_name
    if self.role.present?
      self.role.name
    end
  end

  def person_role_formatted
    "#{name} - #{role_name}"
  end

  def name
    person.name if person
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    visible false

    # group with publication in navigation
    parent Publication

    # configuration
    configure :role do
      pretty_value do
        bindings[:object].role_name
      end

      # sort the names
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.sort_name_asc
        }
      end
    end
    configure :person do
      # limit to only published person
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.sort_name_asc
        }
      end
    end

    # list page

    # show page

    # form
    edit do
      field :person do
        help I18n.t('admin.help.person')
      end
      field :role
    end
  end

end
