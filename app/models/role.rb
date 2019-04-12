# == Schema Information
#
# Table name: roles
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  has_many :person_roles, dependent: :destroy

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################

  #################
  ## SCOPES ##
  #################
  scope :sort_name, -> { with_translations(I18n.locale).order('role_translations.name asc') }
  scope :illustrators, -> { where(is_illustrator: true) }

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.supporting')

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 150

    # list page
    list do
      field :name
      field :is_illustrator
    end

    # show page
    show do
      field :name
      field :is_illustrator
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end
      field :is_illustrator do
        help I18n.t('admin.help.is_illustrator')
      end
    end
  end

end
