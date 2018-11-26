class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  #################
  ## PRIVATE METHODS ##
  #################
  private

  # if a translation is marked as public
  # make sure the required fields are provided
  # - required_fields = array of fields names as strings
  #   ex: ['title', 'summary']
  def check_public_required_fields(required_fields)

    self.is_public_translations.each do |locale, flag|
      if flag == true
        # is public = true, check required fields

        record = self.translations.select{|x| x.locale.to_s == locale}.first

        if record
          required_fields.each do |required_field|
            if self.send("#{required_field}_translations")[locale].nil? || self.send("#{required_field}_translations")[locale].empty?
              # value does not exist - add validation error
              record.errors.add required_field, I18n.t('admin.errors.required_for_publication')
            end
          end

          record.errors.full_messages.each do |msg|
            # add the error message to the base so it is shown at the top of the page
            errors[:base] << I18n.t('labels.language_error', lang: locale.upcase, msg: msg)
          end
        end
      end
    end
  end


  # check each language and if the is_public is being set to true,
  # then also set the publish date
  def set_publish_dates
    self.is_public_translations.each do |locale, flag|
      if flag == true
        # is public = true, check date
        if self.date_publish_translations[locale].nil?
          # date does not exist, set it
          self.attributes = {date_publish: Time.now, locale: locale}
        end
      end
    end
  end

end
