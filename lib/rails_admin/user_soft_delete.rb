# taken from: http://blog.paulrugelhiatt.com/ruby/rails/2014/10/27/rails-admin-custom-action-example.html
# while basically copying the delete action: https://github.com/sferik/rails_admin/blob/master/lib/rails_admin/config/actions/delete.rb
module RailsAdmin
  module Config
    module Actions
      class UserSoftDelete < RailsAdmin::Config::Actions::Base
        # This ensures the action only shows up for Users
        register_instance_option :visible? do
          authorized? && bindings[:object].class == User
        end

        register_instance_option :member do
          true
        end

        register_instance_option :route_fragment do
          'soft_delete'
        end

        register_instance_option :http_methods do
          [:get, :delete]
        end

        register_instance_option :authorization_key do
          :destroy
        end

        register_instance_option :link_icon do
          'icon-remove'
        end

        register_instance_option :controller do
          proc do
            if request.get? # DELETE

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.delete? # DESTROY

              redirect_path = nil
              @auditing_adapter && @auditing_adapter.delete_object(@object, @abstract_model, _current_user)
              if @object.soft_delete
                flash[:success] = t('admin.flash.successful', name: @model_config.label, action: t('admin.actions.delete.done'))
                redirect_path = index_path
              else
                flash[:error] = t('admin.flash.error', name: @model_config.label, action: t('admin.actions.delete.done'))
                redirect_path = back_or_index
              end

              redirect_to redirect_path

            end
          end
        end

      end
    end
  end
end