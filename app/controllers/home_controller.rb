class HomeController < ApplicationController

  def index
    @publications = Publication.published.sort_published_desc.limit(3)
    @news = News.published.sort_published_desc.limit(3)
    @illustrations = Illustration.published.sort_published_desc.limit(3)
    # @highlights = Highlight.published.sort_published_desc
    # @stats = {}
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

  end
end
