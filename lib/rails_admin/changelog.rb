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
            file = Rails.root.join("CHANGELOG.md")
            cache_key = [file, File.mtime(file)].join('-')

            # taken from here: https://richonrails.com/articles/rendering-markdown-with-redcarpet
            @changelog_html = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
              options = {
                filter_html:     true,
                hard_wrap:       true,
                link_attributes: { rel: 'nofollow', target: "_blank" },
                space_after_headers: true,
                fenced_code_blocks: true
              }

              extensions = {
                autolink:           true,
                superscript:        true,
                disable_indented_code_blocks: true
              }

              renderer = Redcarpet::Render::HTML.new(options)
              markdown = Redcarpet::Markdown.new(renderer, extensions)

              markdown.render(File.read(file)).html_safe
            end

            # @changelog_html = get_changelog_html

            respond_to do |format|
              format.html { render @action.template_name }
            end

          end
        end

      end
    end
  end
end