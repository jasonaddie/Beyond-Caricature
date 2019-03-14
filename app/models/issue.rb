# == Schema Information
#
# Table name: issues
#
#  id                :bigint(8)        not null, primary key
#  publication_id    :bigint(8)
#  issue_number      :string
#  date_publication  :date
#  is_public         :boolean          default(FALSE)
#  date_publish      :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_uid   :string
#  scanned_file_uid  :string
#  slug              :string
#  scanned_file_size :integer
#

class Issue < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ATTACHED FILES ##
  #################
  dragonfly_accessor :scanned_file
  dragonfly_accessor :cover_image do
    default Rails.root.join('public','images','default-wide.png')
  end


  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :publication, -> { journals }, inverse_of: :issues
  has_many :illustration_issues, dependent: :destroy
  has_many :illustrations, through: :illustration_issues
  has_many :related_items, dependent: :nullify

  #################
  ## SLUG
  #################
  extend FriendlyId
  friendly_id :issue_number, use: [:slugged]

  # for genereate friendly_id
  def should_generate_new_friendly_id?
    super
  end

  # for locale sensitive transliteration with friendly_id
  def normalize_friendly_id(input)
    input.to_s.to_url
  end

  #################
  ## VALIDATION ##
  #################
  validates :issue_number, presence: true
  validates :date_publication, presence: true
  validates_size_of :cover_image, maximum: 5.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']
  validates_property :ext, of: :scanned_file, as: 'pdf'

  #################
  ## CALLBACKS ##
  #################
  before_save :set_publish_date

  #################
  ## METHODS ##
  #################
  def illustration_count
    self.illustration_issues.count
  end

  # journal name and issue number
  def full_title
    if self.publication
      "#{self.publication.title} - #{self.issue_number}"
    else
      self.issue_number
    end
  end

  #################
  ## SCOPES ##
  #################
  scope :published, -> { where(is_public: true) }
  scope :sort_published_desc, -> { order(date_publish: :desc) }
  scope :sort_publication_desc, -> { order(date_publication: :desc) }

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.primary')

    # control the order in the admin nav menu
    weight 30

    # configuration
    configure :date_publish do
      date_format :default
      datepicker_options showTodayButton: true, format: 'YYYY-MM-DD'
    end
    configure :date_publication do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    # publication list should only show journals
    configure :publication do
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:publication).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end
    configure :cover_image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end
    # create link to file
    configure :scanned_file do
      html_attributes required: required? && !value.present?, accept: '.pdf'
      image false
      pretty_value do
        if bindings[:object].scanned_file.present?
          bindings[:view].content_tag(:a,
            I18n.t('labels.view_file_with_size', size: ActionController::Base.helpers.number_to_human_size(bindings[:object].scanned_file_size)),
            href: bindings[:object].scanned_file.url,
            target: '_blank',
            class: 'btn btn-info btn-sm'
          )
        end
      end
    end

    # list page
    list do
      field :is_public
      field :cover_image
      field :publication
      field :issue_number
      field :date_publication
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :date_publish
    end

    # show page
    show do
      field :is_public
      field :publication
      field :issue_number
      field :date_publication
      field :cover_image
      field :scanned_file
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :is_public
      field :publication do
        inline_add false
        inline_edit false
      end
      field :issue_number
      field :date_publication
      field :cover_image do
        help I18n.t('admin.help.image')
      end
      field :scanned_file do
        help I18n.t('admin.help.file')
      end
    end
  end

end
