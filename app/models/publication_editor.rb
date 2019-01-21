# == Schema Information
#
# Table name: publication_editors
#
#  id             :bigint(8)        not null, primary key
#  publication_id :bigint(8)
#  year_start     :integer
#  year_end       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PublicationEditor < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication

  #################
  ## TRANSLATIONS ##
  #################
  translates :editor, :publisher, :versioning => :paper_trail
  accepts_nested_attributes_for :translations, allow_destroy: true

  #################
  ## VALIDATION ##
  #################
  validates :year_start, numericality: { greater_than: 1800, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year_start.blank? }
  validates :year_end, numericality: { greater_than_or_equal_to: :year_start, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year_end.blank? }

  #################
  ## CALLBACKS ##
  #################
  validate :check_association_public_required_fields

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    visible false

    # group with publication in navigation
    parent Publication

    configure :translations, :globalize_tabs

    # configuration

    # list page

    # show page

    # form
    edit do
      field :translations do
        label I18n.t('labels.translations')
      end

      field :year_start
      field :year_end
    end
  end

  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_association_public_required_fields
    # call the methohd in the application record base object
    super(['editor'], self.publication)
  end

end
