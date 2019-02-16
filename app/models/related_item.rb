# == Schema Information
#
# Table name: related_items
#
#  id                 :bigint(8)        not null, primary key
#  related_item_type  :integer
#  news_itemable_id   :integer
#  news_itemable_type :string
#  publication_id     :bigint(8)
#  illustration_id    :bigint(8)
#  illustrator_id     :bigint(8)
#  issue_id           :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class RelatedItem < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail


  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :news_itemable, polymorphic: true
  belongs_to :publication, -> { published }, optional: true
  belongs_to :illustrator, -> { published }, optional: true
  belongs_to :illustration, -> { published }, optional: true
  belongs_to :issue, -> { published }, optional: true

  #################
  ## ENUMS ##
  #################
  enum related_item_type: [:publication, :issue, :illustration, :illustrator]

  #################
  ## VALIDATION ##
  #################
  validates :related_item_type, presence: true
  validate :provided_reference

  #################
  ## SCOPES ##
  #################
  def self.related_item_types_for_select
    options = {}
    related_item_types.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.related_item_types.#{key}")] = value
    end
    return options
  end


  #################
  ## METHODS ##
  #################
  # return the title of the published item this record is tied to
  def item_title
    if self.publication?
      self.publication.title
    elsif self.issue?
      self.issue.full_title
    elsif self.illustration?
      self.illustration.title
    elsif self.illustrator?
      self.illustrator.name
    end
  end

  # return the link to the published item this record is tied to
  def item_link
    if self.publication?
      Rails.application.routes.url_helpers.publication_path(I18n.locale, self.publication)
    elsif self.issue?
      Rails.application.routes.url_helpers.issue_path(I18n.locale, self.issue.publication, self.issue)
    elsif self.illustration?
      Rails.application.routes.url_helpers.illustration_path(I18n.locale, self.illustration)
    elsif self.illustrator?
      Rails.application.routes.url_helpers.illustrator_path(I18n.locale, self.illustrator)
    end
  end

  # show the translated name of the enum value
  def related_item_type_formatted
    self.related_item_type? ? I18n.t("activerecord.attributes.#{model_name.i18n_key}.related_item_types.#{related_item_type}") : nil
  end


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    visible false

    # group with News in navigation
    parent News

    # configuration
    configure :publication do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:publication).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end

    configure :issue do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:issue).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end

    configure :illustration do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:illustration).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end

    configure :illustrator do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:illustrator).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end

    configure :related_item_type do
      # enum RelatedItem.related_item_types_for_select
      pretty_value do
        bindings[:object].related_item_type_formatted
      end
    end


    # list page

    # show page

    # form
    edit do
      field :related_item_type do
        html_attributes class: 'related-item-type'
      end
      field :publication do
        html_attributes class: 'related-item publication'
        inline_add false
        inline_edit false
        help I18n.t('admin.help.only_public_items')
      end
      field :issue do
        html_attributes class: 'related-item issue'
        inline_add false
        inline_edit false
        help I18n.t('admin.help.only_public_items')
      end
      field :illustration do
        html_attributes class: 'related-item illustration'
        inline_add false
        inline_edit false
        help I18n.t('admin.help.only_public_items')
      end
      field :illustrator do
        html_attributes class: 'related-item illustrator'
        inline_add false
        inline_edit false
        help I18n.t('admin.help.only_public_items')
      end
    end
  end


  private


  #################
  ## VALIDATION ##
  #################
  # make sure that for the provided related item type,
  # the corresponding reference is provided
  def provided_reference
    if self.publication? && self.publication_id.nil?
      self.errors.add :publication_id, I18n.t('admin.errors.required_related_item')

    elsif self.issue? && self.issue_id.nil?
      self.errors.add :issue_id, I18n.t('admin.errors.required_related_item')

    elsif self.illustration? && self.illustration_id.nil?
      self.errors.add :illustration_id, I18n.t('admin.errors.required_related_item')

    elsif self.illustrator? && self.illustrator_id.nil?
      self.errors.add :illustrator_id, I18n.t('admin.errors.required_related_item')
    end
  end
end
