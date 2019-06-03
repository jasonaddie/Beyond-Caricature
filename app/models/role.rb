# == Schema Information
#
# Table name: roles
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  is_illustrator :boolean          default(FALSE)
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
  has_many :people, through: :person_roles

  #################
  ## TRANSLATIONS ##
  #################
  translates :name, :slug, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## SLUG
  #################
  extend FriendlyId
  include GlobalizeFriendlyId # overriden and extra methods for friendly id located in concern folder
  friendly_id :slug_candidates, use: [:globalize, :history, :slugged]

  # give options of what to use when the slug is already in use by another record
  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end

  #################
  ## VALIDATION ##
  #################

  #################
  ## SCOPES ##
  #################
  scope :sort_name_asc, -> { select('roles.*, role_translations.name').with_translations(I18n.locale).order('role_translations.name asc') }
  scope :illustrators, -> { where(is_illustrator: true) }
  scope :with_published_people, -> { joins(:people) }

  # get all roles that are assigned to published illustrations
  def self.with_published_illustrations
    # get all published illustrations with a person role record
    illustration_ids = Illustration.published.where(id: PersonRole.where(person_roleable_type: 'Illustration').pluck(:person_roleable_id).uniq).pluck(:id).uniq
    if illustration_ids.present?
      self.where(id: PersonRole.where(person_roleable_type: 'Illustration', person_roleable_id: illustration_ids).pluck(:role_id)).distinct
    else
      return self
    end
  end

  # get all roles that are assigned to published publications
  # - have to check both publication and publication editor roles
  def self.with_published_publications
    # get all role records assigned to a publication
    pub_roles = PersonRole.where(person_roleable_type: 'Publication')
    pub_editor_roles = PersonRole.where(person_roleable_type: 'PublicationEditor')

    publication_ids = []
    pub_editors = nil
    if pub_roles.present?
      # get publication ids
      publication_ids << pub_roles.map{|x| x.person_roleable_id}
    end
    if pub_editor_roles.present?
      # get publication ids from publication editor records
      pub_editors = PublicationEditor.where(id: pub_editor_roles.map{|x| x.person_roleable_id}).pluck(:id, :publication_id).uniq
      publication_ids << pub_editors.map{|x| x[1]}.uniq
    end
    # make sure we only have unique publication ids
    publication_ids = publication_ids.flatten.uniq

    # figure out which ones are published
    published_publication_ids = Publication.published.where(id: publication_ids).pluck(:id).uniq

    if published_publication_ids.present?
      # pull the role_id from the roles that are assigned to the published records
      role_ids = []
      if pub_roles.present?
        role_ids << pub_roles.select{|x| published_publication_ids.include?(x.person_roleable_id) }.map{|x| x.role_id}
      end
      if pub_editor_roles.present?
        published_pub_editors = pub_editors.select{|x| published_publication_ids.include?(x[1])}.uniq
        role_ids << pub_editor_roles.select{|x| published_pub_editors.include?(x.person_roleable_id) }.map{|x| x.role_id}
      end
      # make sure we only have unique ids
      role_ids = role_ids.flatten.uniq

      if role_ids.present?
        self.where(id: role_ids).distinct
      else
        self
      end
    else
      return self
    end
  end


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
