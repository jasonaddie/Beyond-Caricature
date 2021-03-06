# == Schema Information
#
# Table name: issues
#
#  id                :bigint(8)        not null, primary key
#  publication_id    :bigint(8)
#  issue_number      :string
#  date_publication  :date
#  is_public         :boolean          default(FALSE)
#  date_publish_old  :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_uid   :string
#  scanned_file_uid  :string
#  slug              :string
#  scanned_file_size :integer
#  crop_alignment    :string           default("center")
#  published_at      :datetime
#

class Issue < ApplicationRecord
  include FullTextSearch
  include CropAlignment

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

  friendly_id :slug_candidates, use: [:slugged]

  # give options of what to use when the slug is already in use by another record
  def slug_candidates
    [
      :issue_number,
      [:issue_number, :date_publication]
    ]
  end

  # override to create new slug if there is text and the existing value is nil or does not match
  # from: https://github.com/norman/friendly_id-globalize/blob/master/lib/friendly_id/globalize.rb
  def should_generate_new_friendly_id?
    send(slug_candidates.first).present? && !slug_candidate_values.include?(send(friendly_id_config.slug_column))
  end

  # use the current model values to generate all possible slugs from the slug candidates
  def slug_candidate_values
    values = []

    slug_candidates.each do |candidate|
      slug = ''
      if candidate.class == Array
        candidate.each do |candidate_field|
          slug << send(candidate_field).to_s
          slug << ' '
        end
      else
        slug << send(candidate).to_s
      end

      values << normalize_friendly_id(slug.strip)
    end

    return values
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
  validates_size_of :scanned_file, maximum: 30.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']
  validates_property :ext, of: :scanned_file, as: 'pdf'

  #################
  ## CALLBACKS ##
  #################
  before_save :set_published_at

  #################
  ## SCOPES ##
  #################
  scope :published, -> { where(is_public: true) }
  scope :sort_published_desc, -> { order(published_at: :desc) }
  scope :sort_publication_desc, -> { order(date_publication: :desc) }

  # search query for the list admin page
  # - issue number
  # - journal name
  def self.admin_search(q)
    ids = []

    # issue number
    issues = self.where(build_full_text_search_sql(%w(issue_number)),
            q
          ).pluck(:id)

    if issues.present?
      ids << issues
    end

    # journal name
    journals = Publication.with_translations(I18n.locale)
          .journals
          .where(build_full_text_search_sql(%w(publication_translations.title)),
            q
          ).pluck(:id)

    if journals.present?
      jounral_issues = self.where(publication_id: journals).pluck(:id)
      if jounral_issues.present?
        ids << jounral_issues
      end
    end

    ids = ids.flatten.uniq

    if ids.present?
      self.where(id: ids).distinct
    else
      self.none
    end
  end

  # get the min and max dates on record
  # and return in format: start - end
  def self.start_end_dates
    string = nil
    dates = self.all.pluck(:date_publication).sort

    if dates.present?
      string = I18n.l(dates.first)
      if dates.length > 1
        string << ' - '
        string << I18n.l(dates.last)
      end
    end

    return string
  end

  #################
  ## METHODS ##
  #################
  def illustration_count
    self.illustrations.published.count
  end

  def issue_number_formatted
    x = ''
    if self.issue_number.present?
      x = "№ #{self.issue_number}"
      if self.date_publication.present?
        x << " (#{self.date_publication.year})"
      end
    end

    return x
  end

  # journal name and issue number
  def full_title
    if self.publication
      "#{self.publication.title}, #{issue_number_formatted}"
    else
      issue_number_formatted
    end
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.primary')

    # control the order in the admin nav menu
    weight 30

    # configuration
    configure :date_publication do
      date_format :default
      datepicker_options showTodayButton: false, format: 'YYYY-MM-DD', viewMode: 'years', minDate: '1800-01-01', maxDate: "#{Time.now.year}-12-31"
    end
    configure :publication do
      # limit to only published items that are journals
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.published.journals
        }
      end
    end
    configure :cover_image do
      html_attributes required: required? && !value.present?, accept: 'image/*'
    end
    configure :crop_alignment do
      pretty_value do
        bindings[:view].content_tag(:div, bindings[:object].crop_alignment_formatted) +
        if bindings[:object].cover_image.present?
          bindings[:view].tag(:br) +
          bindings[:view].image_tag(bindings[:object].cover_image.thumb(bindings[:object].generate_image_size_syntax(:square_small)).url, class: 'img-thumbnail')
        end
      end
    end
    # create link to file
    configure :scanned_file do
      html_attributes required: required? && !value.present?, accept: '.pdf'
      image false
      pretty_value do
        if bindings[:object].scanned_file.present?
          bindings[:view].content_tag(:a,
            I18n.t('labels.view_file_with_size',
                size: ActionController::Base.helpers.number_to_human_size(bindings[:object].scanned_file_size),
                name: I18n.t('labels.meta.issue_number')),
            href: bindings[:object].scanned_file.url,
            target: '_blank',
            class: 'btn btn-info btn-sm'
          )
        end
      end
    end

    configure :published_at do
      # remove the time zone
      pretty_value do
        value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
      end
    end

    configure :updated_at do
      # remove the time zone
      pretty_value do
        value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
      end
    end

    # list page
    list do
      search_by :admin_search

      field :is_public
      field :cover_image
      field :publication
      field :issue_number
      field :date_publication
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :published_at
      field :updated_at
    end

    # show page
    show do
      field :is_public
      field :publication
      field :issue_number
      field :date_publication
      field :cover_image do
        thumb_method '150x'
      end
      field :crop_alignment
      field :scanned_file
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :published_at
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
      field :crop_alignment do
        help I18n.t('admin.help.crop_alignment')
      end
      field :scanned_file do
        help I18n.t('admin.help.file')
      end
    end
  end

end
