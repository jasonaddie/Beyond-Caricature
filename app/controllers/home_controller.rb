class HomeController < ApplicationController

  def index
    @publications = Publication.published.sort_published_desc.limit(3)
    @news = News.published.sort_published_desc.limit(3)
    @illustrations = Illustration.published.sort_published_desc.limit(3)
    @stats = get_stats
    @highlights = Highlight.published.sort_published_desc

    @page = PageContent.with_translations(I18n.locale).find_by_name('homepage_intro')
  end

  def sources
    @publications = Publication.published.sort_published_desc
  end

  def source
    @publication = Publication.friendly.published.find(params[:id])
  end

  def issue
    @publication = Publication.friendly.published.find(params[:publication_id])
    @issue = @publication.issues.friendly.published.find(params[:id]) if @publication
  end

  def illustrations
    @illustrations = Illustration.published.sort_published_desc
  end

  def illustration
    @illustration = Illustration.friendly.published.find(params[:id])
  end

  def illustrators
    @illustrators = Illustrator.published.sort_published_desc
  end

  def illustrator
    @illustrator = Illustrator.friendly.published.find(params[:id])
  end

  def people
    @people = Person.published.sort_published_desc
  end

  def person
    @person = Person.friendly.published.find(params[:id])
  end

  def news
    @news = News.published.sort_published_desc
  end

  def news_item
    @news_item = News.friendly.published.find(params[:id])
  end

  def researches
    @researches = Research.published.sort_published_desc
  end

  def research
    @research = Research.friendly.published.find(params[:id])
  end

  def about
    @page = PageContent.with_translations(I18n.locale).find_by_name('about')
  end

  def robots
    # load the robots.text file
  end

private

  # get counts for the following:
  # journal issues | issue illustrations
  # book | book illustrations
  # original | original illustrations
  # illustrator | illustrator illustration
  def get_stats
    stats = {}

      # issues
      ids = Issue.published.pluck(:id)
      stats[:journal_issues] = {}
      stats[:journal_issues][:count] = ids.count
      stats[:journal_issues][:illustrations] = IllustrationIssue.where(issue_id: ids).count

      # books
      ids = Publication.published.book.pluck(:id)
      stats[:books] = {}
      stats[:books][:count] = ids.count
      stats[:books][:illustrations] = IllustrationPublication.where(publication_id: ids).count

      # originals
      ids = Publication.published.original.pluck(:id)
      stats[:originals] = {}
      stats[:originals][:count] = ids.count
      stats[:originals][:illustrations] = IllustrationPublication.where(publication_id: ids).count

      # illustrators
      ids = PersonRole.illustrators
      stats[:illustrators] = {}
      stats[:illustrators][:count] = ids.map{|x| x.person_id}.uniq.length
      stats[:illustrators][:illustrations] = Illustration.published.where(id: ids.map{|x| x.person_roleable_id}.uniq).count

    return stats
  end
end
