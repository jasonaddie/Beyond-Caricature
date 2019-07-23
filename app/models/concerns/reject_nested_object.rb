module RejectNestedObject
  extend ActiveSupport::Concern

  included do

    # if there are not values in the provided data_object for the fie fields
    # list in non-translation and translation fields
    # then return true
    # else return false
    # attributes:
    # - data_object - hash of data submitted from the form
    # - nontranslation_fields - array of field names to check for values that are not translation fields
    #   - field names can be string or hash
    #     - a hash is needed if there is a nested attribute object
    #       for instance, data_object is: {"year_start"=>"1999", "year_end"=>"", "person_roles_attributes"=>{"0"=>{"person_id"=>"12", "role_id"=>"19"}}}
    #       so the fields will be: ['year_start', 'year_end', {"person_roles_attributes": ["person_id", "role_id"]}]
    # - translation_fields - array of field names to check for values
    #   - field names can only be strings
    def self.reject_nested_object?(data_object, nontranslation_fields=nil, translation_fields=nil)
      found_value = false

      # check nontranslation fields first
      if !nontranslation_fields.nil? && !nontranslation_fields.empty?
        nontranslation_fields.each do |field|
          if field.class == String
            if !data_object[field].blank?
              found_value = true
              break
            end
          elsif field.class == Hash && !field.empty?
            field.each do |sub_attribute, sub_fields|
              if !data_object[sub_attribute.to_s].empty?
                # the format is attributes: {obj_id: {key: value, key: value}, obj_id: {key: value, key: value}}
                # so must loop through each obj_id
                data_object[sub_attribute.to_s].each do |obj_id, sub_values|
                  sub_fields.each do |sub_field|
                    if !sub_values[sub_field].blank?
                      found_value = true
                      break
                    end
                  end
                  break if found_value
                end
                break if found_value
              end
            end
          end
        end
      end

      if !found_value && !translation_fields.nil? && !translation_fields.empty?
        # no nontranslation value so now check translation value
        # format is {"translations_attributes"=>{"0"=>{"locale"=>"", "field"=>""}, "1"=>{"locale"=>"", "field"=>""}, ... }
        # so get values of translations_attributes hash and then check the field values
        data_object["translations_attributes"].values.each do |trans_values|
          translation_fields.each do |field|
            if !trans_values[field].blank?
              found_value = true
              break
            end
          end
          break if found_value
        end
      end

      return !found_value
    end

  end
end