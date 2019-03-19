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
  has_many :editor_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :editors, -> { published.with_roles('editor') }, through: :editor_people, source: :person
  has_many :publisher_people, as: :person_roleable, class_name: 'PersonRole', dependent: :destroy
  has_many :publishers, -> { published.with_roles('publisher') }, through: :publisher_people, source: :person

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

    # configuration
    configure :editors do
      # limit to only published editors
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('editor').sort_name
        }
      end
    end
    configure :publishers do
      # limit to only published publishers
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.with_roles('publisher').sort_name
        }
      end
    end

    # list page

    # show page

    # form
    edit do

      field :editors do
        help I18n.t('admin.help.person.editor')
      end
      field :publishers do
        help I18n.t('admin.help.person.publisher')
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
    # super(['editor'], self.publication)
  end

end
