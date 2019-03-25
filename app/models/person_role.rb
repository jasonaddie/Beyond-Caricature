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
#  role                 :integer
#

class PersonRole < ApplicationRecord
  # extend ArrayEnum

  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :person, -> { published }
  belongs_to :person_roleable, :polymorphic => true

  #################
  ## ENUMS ##
  #################
  ROLES = {'illustrator' => 1, 'editor' => 2, 'publisher' => 3, 'writer' => 4, 'printer' => 5, 'financier' => 6, 'official' => 7, 'subject' => 8}
  enum role: ROLES

  #################
  ## VALIDATION ##
  #################

  #################
  ## SCOPES ##
  #################
  def self.roles_for_select
    options = {}
    ROLES.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.role_types.#{key}")] = key
    end
    return options
  end

  # group the person records by the role
  def self.group_records_by_role
    groups = {}
    roles = self.pluck(:role).uniq.sort

    if roles.present?
      roles.each do |role|
        groups[I18n.t("activerecord.attributes.#{model_name.i18n_key}.role_types.#{role}")] = self.where(role: role).includes(:person).order('person_translations.name asc')
      end
    end

    return groups
  end

  # get list of unique roles
  def self.unique_roles
    roles = []
    records = self.all
    uniq_roles = records.map{|x| x.role}.uniq.reject(&:nil?)

    if uniq_roles.present?
      uniq_roles.sort.each do |role|
        roles << {
          key: role,
          name: I18n.t("activerecord.attributes.#{model_name.i18n_key}.role_types.#{role}"),
          count: records.select{|x| x.role == role}.count
        }
      end
    end

    return roles
  end

  #################
  ## METHODS ##
  #################
  # show the translated name of the enum value
  def role_formatted
    if self.role.present?
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.role_types.#{role}")
    end
  end

  def person_role_formatted
    "#{name} - #{role_formatted}"
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
        bindings[:object].role_formatted
      end
    end
    configure :person do
      # limit to only published person
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.sort_name
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
      field :role do
        # options_for_select PersonRole.roles_for_select
      end
    end
  end

end
