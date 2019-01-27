# custom root action to show the changelog
module RailsAdmin
  module Config
    module Actions
      class Changelog < RailsAdmin::Config::Actions::Base
        # root level action (not tied to model)
        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          proc do

            # this calls a method in application helper
            @changelog_html = get_changelog_as_html

            respond_to do |format|
              format.html { render @action.template_name }
            end

          end
        end

      end
    end
  end
end