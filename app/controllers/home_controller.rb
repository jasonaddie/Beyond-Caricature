class HomeController < ApplicationController

  before_action :set_pagination_values
  before_action :clean_search_query


  def index
    @publications = Publication.published.sort_published_desc.limit(3)
    @news = News.published.sort_published_desc.limit(3)
    @illustrations = Illustration.published.sort_published_desc.limit(3)
    @stats = get_stats
    @highlights = Highlight.published.sort_published_desc

    @page = PageContent.with_translations(I18n.locale).find_by_name('homepage_intro')
  end

  def sources
    @publications = Publication.published
                      .filter({search: params[:search], type: params[:type],
                                language: params[:language], person: params[:person], role: params[:role],
                                date_start: convert_date_param(:date_start), date_end: convert_date_param(:date_end)})
                      .sort_name_asc.page(params[:page]).per(@pagination_per_large)
    @filter_source_types = Publication.publication_types_for_select2
    @filter_languages = PublicationLanguage.active.sort_language_asc.with_published_publications
    @filter_date_ranges = Publication.date_ranges
    @filter_roles = Role.with_published_publications.sort_name_asc
    @filter_people = Person.with_published_publications.published.sort_name_asc
  end

  def source
    @publication = Publication.friendly.published.find(params[:id])
  end

  def issue
    @publication = Publication.friendly.published.find(params[:publication_id])
    @issue = @publication.issues.friendly.published.find(params[:id]) if @publication
  end

  def images
    @illustrations = Illustration.published
                        .filter({search: params[:search], type: params[:type],
                                person: params[:person], role: params[:role],
                                tag: params[:tag], source: params[:source],
                                journal: params[:journal], issue: params[:issue],
                                date_start: convert_date_param(:date_start), date_end: convert_date_param(:date_end)})
                        .sort_published_desc.page(params[:page]).per(@pagination_per_large)
    @filter_source_types = Publication.publication_types_for_select2
    @filter_people = Person.with_published_illustrations.published.sort_name_asc
    @filter_date_ranges = Illustration.date_ranges
    @filter_roles = Role.with_published_illustrations.sort_name_asc
    @filter_tags = Tag.with_published_illustrations.sort_name_asc
  end

  def image
    @illustration = Illustration.friendly.published.find(params[:id])
  end

  def people
    @people = Person.published
                .filter({search: params[:search], role: params[:role],
                          date_start: convert_date_param(:date_start), date_end: convert_date_param(:date_end)})
                .sort_name_asc.page(params[:page]).per(@pagination_per_large)
    @filter_roles = Role.with_published_people.sort_name_asc.uniq
    @filter_date_ranges = Person.date_ranges
  end

  def person
    @person = Person.friendly.published.find(params[:id])
  end

  def news
    @news = News.published
                .filter({search: params[:search],
                        date_start: convert_date_param(:date_start), date_end: convert_date_param(:date_end)})
                .sort_published_desc.page(params[:page]).per(@pagination_per_small)
    @filter_date_ranges = News.date_ranges
  end

  def news_item
    @news_item = News.friendly.published.find(params[:id])
  end

  def researches
    @researches = Research.published
                          .filter({search: params[:search],
                                    date_start: convert_date_param(:date_start), date_end: convert_date_param(:date_end)})
                          .sort_published_desc.page(params[:page]).per(@pagination_per_small)
    @filter_date_ranges = Research.date_ranges
  end

  def research
    @research = Research.friendly.published.find(params[:id])
  end

  def about
    @about = PageContent.with_translations(I18n.locale).find_by_name('about')
    @contributors = PageContent.with_translations(I18n.locale).find_by_name('contributors')
  end

  def robots
    # load the robots.text file
  end

private

  # get counts for the following:
  # Journals, Journal Issues, Books, Originals, Images, People, Research, Languages
  def get_stats
    stats = {}

      stats[:journals] = Publication.published.journal.count
      stats[:journal_issues] = Issue.published.count
      stats[:books] = Publication.published.book.count
      stats[:originals] = Publication.published.original.count
      stats[:illustrations] = Illustration.published.count
      stats[:people] = Person.published.count
      stats[:research] = Research.published.count
      stats[:languages] = Publication.published.select(:publication_language_id).distinct.count

    return stats
  end


  def set_pagination_values
    if params[:page].nil? || params[:page].to_i == 0
      params[:page] = 1
    end

    @pagination_per_large = 12
    @pagination_per_small = 4
  end

  def clean_search_query
    params[:search] = params[:search].present? ? params[:search].gsub("'", "").gsub('"', '') : nil
  end

  def convert_date_param(param_key)
    d = nil
    if params[param_key].present?
      begin
        if /^\d\d\d\d-[0-1][1-9]-[0-3]\d$/.match?(params[param_key])
          d = Date.parse(params[param_key])
        else
          # reset the param value
          params[param_key] = nil
        end
      rescue
        # do nothing
      end
    end

    return d
  end
end
