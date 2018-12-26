# == Schema Information
#
# Table name: slideshows
#
#  id             :bigint(8)        not null, primary key
#  sort           :integer
#  image_uid      :string
#  imageable_type :string
#  imageable_id   :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Slideshow < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail


  #################
  ## ATTACHED FILES ##
  #################
  dragonfly_accessor :image


  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :imageable, polymorphic: true

  #################
  ## VALIDATION ##
  #################
  validates :sort, presence: true
  validates :image, presence: true
  validates_size_of :image, maximum: 5.megabytes
  validates_property :ext, of: :image, in: ['jpg', 'jpeg', 'png']


  #################
  ## SCOPES ##
  #################
  def self.sorted
    order(sort: :asc, id: :asc)
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    visible false

    # group with News in navigation
    parent News

    # configuration
    configure :image do
      html_attributes accept: 'image/*'
    end

    # list page

    # show page

    # form
    edit do
      field :image
      field :sort do
        help I18n.t('admin.help.sort')
      end
    end
  end

end
