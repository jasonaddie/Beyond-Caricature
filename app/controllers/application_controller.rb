class ApplicationController < ActionController::Base

  before_action :set_paper_trail_whodunnit

  #################
  ## LOCALES ##
  #################
  # make sure the locale is set if it does not exist in the url
  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  # make sure locale is in url
  def default_url_options
    { locale: I18n.locale }
  end
end
