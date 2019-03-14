require 'rails_admin/config/fields/association'

module RailsAdmin
  module Config
    module Fields
      module Types
        class ArrayField < RailsAdmin::Config::Fields::Base
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types.register(self)

          register_instance_option :partial do
            :array_form
          end

          register_instance_option :options_for_select do
            []
          end

          # have to convert the integers into the keys
          # this is specific to person roles
          register_instance_option :formatted_keys do
            bindings[:object].safe_send('roles_keys')
          end
        end
      end
    end
  end
end
