class HomeController < ApplicationController

  def index
    @highlights = Highlight.published.sort_published_desc
  end

  def publications
    @publications = Publication.published.sort_published_desc
  end

  def publication
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
