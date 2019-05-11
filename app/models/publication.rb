# == Schema Information
#
# Table name: publications
#
#  id                      :bigint(8)        not null, primary key
#  publication_type        :integer
#  publication_language_id :bigint(8)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  year                    :integer
#  cover_image_uid         :string
#  scanned_file_uid        :string
#  scanned_file_size       :integer
#

class Publication < ApplicationRecord
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
  belongs_to :publication_language, -> { active }
  has_many :issues, dependent: :nullify
  has_many :illustration_publications, dependent: :destroy
  has_many :illustrations, through: :illustration_publications
  has_many :publication_editors, dependent: :destroy
  has_many :related_items, dependent: :nullify
  accepts_nested_attributes_for :publication_editors, allow_destroy: true,
    reject_if: ->(editor){ reject_publication_editors?(editor)}

  has_many :person_roles, as: :person_roleable, dependent: :destroy
  accepts_nested_attributes_for :person_roles, allow_destroy: true,
    reject_if: ->(role){ reject_person_roles?(role)}


  #################
  ## TRANSLATIONS ##
  #################
  translates :title, :about, :is_public, :date_publish, :slug, :versioning => :paper_trail
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
      :title,
      [:title, :year],
      [:title, :year, :publication_type]
    ]
  end

  #################
  ## ENUMS ##
  #################
  enum publication_type: [:journal, :book, :original]

  #################
  ## VALIDATION ##
  #################
  validates :publication_type, presence: true
  validates :publication_language, presence: true
  validates :year, numericality: { greater_than: 1800, less_than_or_equal_to: Time.now.year }, unless: Proc.new { |x| x.year.blank? }
  validates :publication_editors, presence: true, if: Proc.new{ |x| x.journal? && x.has_public_translation?}
  validates_size_of :cover_image, maximum: 5.megabytes
  validates_property :ext, of: :cover_image, in: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG']
  validates_property :ext, of: :scanned_file, as: 'pdf'

  #################
  ## CALLBACKS ##
  #################
  before_save :set_translation_publish_dates
  validate :check_self_public_required_fields

  #################
  ## SCOPES ##
  #################
  scope :journals, -> { where(publication_type: :journal) }
  scope :not_journals, -> { where.not(publication_type: :journal) }
  scope :published, -> { with_translations(I18n.locale).where('publication_translations.is_public': true) }
  scope :sort_published_desc, -> { order(date_publish: :desc) }
  scope :sort_name_asc, -> { with_translations(I18n.locale).order('publication_translations.title asc, publication_translations.date_publish asc') }

  def self.publication_types_for_select
    options = {}
    publication_types.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{key}")] = value
    end
    return options
  end

  # if there are no values, then reject
  def self.reject_person_roles?(person)
    nontranslation_fields = %w(role_id person)
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

  # if there are no values in all publication editor translations and years, then reject
  def self.reject_publication_editors?(editor)
    nontranslation_fields = %w(editors publishers year_start year_end)
    found_value = false

    # check nontranslation fields first
    nontranslation_fields.each do |field|
      if !editor[field].blank?
        found_value = true
        break
      end
    end

    # if !found_value
    #   # no nontranslation, value so now check translation value
    #   # format is {"translations_attributes"=>{"0"=>{"locale"=>"", "editor"=>"", "publisher"=>""}, "1"=>{"locale"=>"", "editor"=>"", "publisher"=>""}, ... }
    #   # so get values of translations_attributes hash and then check the field values
    #   editor["translations_attributes"].values.each do |trans_values|
    #     translation_fields.each do |field|
    #       if !trans_values[field].blank?
    #         found_value = true
    #         break
    #       end
    #     end
    #     break if found_value
    #   end
    # end

    return !found_value
  end

  #################
  ## METHODS ##
  #################
  def issue_count
    self.issues.published.count if self.journal?
  end

  def illustration_count
    if self.journal?
      self.issues.published.map{|x| x.illustrations.published.count}.inject(0, :+)
    else
      self.illustrations.published.count
    end
  end

  def has_public_translation?
    !self.is_public_translations.values.index(true).nil?
  end

  # show the translated name of the enum value
  def publication_type_formatted
    self.publication_type? ? I18n.t("activerecord.attributes.#{model_name.i18n_key}.publication_types.#{publication_type}") : nil
  end

  def language
    self.publication_language.present? ? self.publication_language.language : nil
  end

  # get the date of the record
  # - for journals, this is based on the issue dates
  # - for book and originals, this is the year
  def date
    if self.journal?
      self.issues.start_end_dates
    else
      self.year.to_s
    end
  end

  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.primary')

    configure :translations, :globalize_tabs
    # control the order in the admin nav menu
    weight 20

    # configuration
    configure :is_public do
      # build an inline list that shows the status of each language
      pretty_value do
        bindings[:view].content_tag(:ul, class: 'list-inline is-public-status') do
          I18n.available_locales.collect do |locale|
            bindings[:view].content_tag(
              :li,
              locale.upcase,
              class: bindings[:object].send("is_public_translations")[locale] ? 'public' : 'not-public',
              title: I18n.t("languages.#{locale}") + ' - ' + I18n.t("status.#{bindings[:object].send("is_public_translations")[locale]}")
            )
          end.join.html_safe
        end
      end
    end
    configure :publication_type do
      # enum Publication.publication_types_for_select
      pretty_value do
        bindings[:object].publication_type_formatted
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
            I18n.t('labels.view_file_with_size',
                    size: ActionController::Base.helpers.number_to_human_size(bindings[:object].scanned_file_size),
                    name: bindings[:object].publication_type_formatted),
            href: bindings[:object].scanned_file.url,
            target: '_blank',
            class: 'btn btn-info btn-sm'
          )
        end
      end
    end
    configure :publication_language do
      # limit to only published issues
      associated_collection_scope do
        resource_scope = bindings[:object].class.reflect_on_association(:publication_language).source_reflection.scope

        proc do |scope|
          resource_scope ? scope.merge(resource_scope) : scope
        end
      end
    end
    configure :about do
      pretty_value do
        value.nil? ? nil : value.html_safe
      end
    end

    configure :publication_editors do
      # build a table listing the editors
      pretty_value do
        bindings[:view].content_tag(:table, class: 'table table-striped publication-editors') do
          bindings[:view].content_tag(:thead) do
            bindings[:view].content_tag(:tr) do
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_start)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:year_end)) +
              bindings[:view].content_tag(:th, PublicationEditor.human_attribute_name(:person_role))
            end
          end +
          bindings[:view].content_tag(:tbody) do
            bindings[:object].publication_editors.collect do |publication_editor|
              bindings[:view].content_tag(:tr) do
                bindings[:view].content_tag(:td, publication_editor.year_start) +
                bindings[:view].content_tag(:td, publication_editor.year_end) +
                bindings[:view].content_tag(:td) do
                  bindings[:view].content_tag(:ul) do
                    publication_editor.person_roles.group_person_records_by_role.collect do |role, people|
                      bindings[:view].content_tag(:li) do
                        bindings[:view].content_tag(:span, role) +
                        bindings[:view].content_tag(:ul) do
                          people.collect do |person|
                            bindings[:view].content_tag(:li) do
                              bindings[:view].link_to(person.name, bindings[:view].url_for(action: 'show', model_name: 'Person', id: person.person_id), class: 'pjax')
                            end
                          end.join.html_safe
                        end
                      end
                    end.join.html_safe
                  end
                end
              end
            end.join.html_safe
          end
        end
      end
    end

    configure :person_roles do
      # build simple list of name and role
      pretty_value do
        bindings[:view].content_tag(:ul) do
          bindings[:object].person_roles.group_people_by_role.collect do |role, people|
            bindings[:view].content_tag(:li) do
              bindings[:view].content_tag(:span, role) +
              bindings[:view].content_tag(:ul) do
                people.collect do |person|
                  bindings[:view].content_tag(:li) do
                    bindings[:view].link_to(person.name, bindings[:view].url_for(action: 'show', model_name: 'Person', id: person.person_id), class: 'pjax')
                  end
                end.join.html_safe
              end
            end
          end.join.html_safe
        end
      end
    end

    # list page
    list do
      field :is_public
      field :cover_image
      field :publication_type
      field :publication_language
      field :title
      field :issue_count do
        label I18n.t('labels.issue_count')
      end
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :date_publish
    end

    # show page
    show do
      field :is_public
      field :cover_image
      field :publication_type
      field :publication_language
      field :scanned_file do
        visible do
          bindings[:object].book? || bindings[:object].original?
        end
      end
      field :title
      field :issue_count do
        label I18n.t('labels.issue_count')
        visible do
          bindings[:object].journal?
        end
      end
      field :illustration_count do
        label I18n.t('labels.illustration_count')
      end
      field :about
      field :publication_editors do
        visible do
          bindings[:object].journal?
        end
      end
      field :person_roles
      field :year do
        visible do
          bindings[:object].book? || bindings[:object].original?
        end
      end
      field :date_publish
      field :created_at
      field :updated_at
    end

    # form
    edit do
      field :publication_type do
        html_attributes class: 'publication-type'
      end
      field :publication_language do
        help I18n.t('admin.help.only_active_languages')
      end
      field :cover_image do
        help "#{I18n.t('admin.help.image_size.publication')} #{I18n.t('admin.help.image')}"
      end
      field :scanned_file do
        css_class 'publication-file'
        help I18n.t('admin.help.file')
      end

      field :translations do
        label I18n.t('labels.translations')
      end

      field :year do
        css_class 'publication-year'
      end

      field :publication_editors do
        css_class 'publication-publication-editors'
      end
      field :person_roles do
        css_class 'publication-person-roles'
      end

    end
  end


  #################
  ## PRIVATE METHODS ##
  #################
  private

  def check_self_public_required_fields
    # call the methohd in the application record base object
    super(%w(title))
  end

end
