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
  belongs_to :publication, optional: true
  belongs_to :illustrator, optional: true
  belongs_to :illustration, optional: true
  belongs_to :issue, optional: true

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
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    visible false

    # group with News in navigation
    parent News

    # configuration

    # list page

    # show page

    # form
    edit do
      field :related_item_type do
        html_attributes class: 'related-item-type'
      end
      field :publication do
        html_attributes class: 'related-item publication'
      end
      field :issue do
        html_attributes class: 'related-item issue'
      end
      field :illustration do
        html_attributes class: 'related-item illustration'
      end
      field :illustrator do
        html_attributes class: 'related-item illustrator'
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
