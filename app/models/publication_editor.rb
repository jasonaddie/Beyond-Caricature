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
  has_many :person_roles, as: :person_roleable, dependent: :destroy
  accepts_nested_attributes_for :person_roles, allow_destroy: true,
    reject_if: ->(role){ reject_person_roles?(role)}

  #################
  ## VALIDATION ##
  #################
  validates :year_start, numericality: { greater_than: 1800, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year_start.blank? }
  validates :year_end, numericality: { greater_than_or_equal_to: :year_start, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year_end.blank? }

  #################
  ## SCOPES ##
  #################
  # if there are no values, then reject
  def self.reject_person_roles?(person)
    nontranslation_fields = %w(role person)
    found_value = false

    # check nontranslation fields first
    nontranslation_fields.each do |field|
      if !person[field].blank?
        found_value = true
        break
      end
    end
    return !found_value
  end

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
    # parent Publication

    # configuration

    # list page

    # show page

    # form
    edit do
      field :year_start
      field :year_end
      field :person_roles
    end
  end

  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_association_public_required_fields
    # call the methohd in the application record base object
    # super(['person_roles'], self.publication)
  end

end
