class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # create way to translate enum values
  def self.human_enum_name(enum_name, enum_value)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
  end

  #### METHODS
  def skip_published_at_callback(value = false)
    @skip_callback = @skip_callback ? @skip_callback : value
  end

  #################
  ## PRIVATE METHODS ##
  #################
  private

  # if a translation is marked as public in the self object
  # make sure the required fields are provided for that translation
  # - required_fields = array of fields names as strings
  #   ex: ['title', 'summary']
  def check_self_public_required_fields(required_fields)
    check_public_required_fields(required_fields, self, self)
  end

  # if a translation is marked as public in the parent object
  # make sure the required fields are provided for that translation
  # - required_fields = array of fields names as strings
  #   ex: ['title', 'summary']
  # - parent - reference the parent object that has the is_public field
  def check_association_public_required_fields(required_fields, parent)
    check_public_required_fields(required_fields, self, parent)
  end

  # if a translation is marked as public
  # make sure the required fields are provided for that translation
  # - required_fields = array of fields names as strings
  #   ex: ['title', 'summary']
  # - self - reference to the object that has the translation fields to validate
  # - parent - reference the parent object that has the is_public field.
  #     If is_public field is in self, then this parameter is not required.
  def check_public_required_fields(required_fields, self_object=self, parent_object=self)
    parent_object.is_public_translations.each do |locale, flag|
      if flag == true
        # is public = true, check required fields

        # check translation records
        check_translation_required_fields(self_object, required_fields, locale)

      end
    end
  end

  # this is called in check_self_public_required_fields
  def check_translation_required_fields(model_object, required_fields, locale)
    record = model_object.translations.select{|x| x.locale.to_s == locale}.first

    if record
      required_fields.each do |required_field|
        if model_object.send("#{required_field}_translations")[locale].nil? || model_object.send("#{required_field}_translations")[locale].empty?
          # value does not exist - add validation error
          record.errors.add required_field, I18n.t('admin.errors.required_for_publication')
        end
      end

      record.errors.full_messages.each do |msg|
        # add the error message to the base so it is shown at the top of the page
        model_object.errors[:base] << I18n.t('labels.language_error', lang: locale.upcase, msg: msg)
      end
    end
  end

  # if the is_public is being set to true,
  # then also set the published_at
  # if the item was public but now is not,
  # reset published_at to nil
  def set_published_at
    if !skip_published_at_callback && self.is_public_changed?
      if self.is_public == true
        self.published_at = Time.now
      elsif self.is_public == false
        self.published_at = nil
      end
    end
  end

  # check each language and if the is_public is being set to true,
  # then also set the published_at
  # if the item was public but now is not,
  # reset published_at to nil
  def set_translation_published_at
    if !skip_published_at_callback
      self.is_public_translations.each do |locale, flag|
        if flag == true
          # is public = true, check date
          if self.published_at_translations[locale].nil?
            # date does not exist, set it
            self.attributes = {published_at: Time.now, locale: locale}
          end
        else
          # is not public, so make sure published_at is nil
          self.attributes = {published_at: nil, locale: locale}
        end
      end
    end
  end

end
