class Users::RegistrationsController < Devise::RegistrationsController

  # DELETE /resource
  # - instead of doing a normal delete - do a soft delete
  # - this just sets a deleted_at date and prevents the user from logging in
  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end
end