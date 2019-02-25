//= require rails_admin/themes/material/ui.js
//= require ckeditor/init
//= require rails_admin/custom/ckeditor_ajax
//= require rails_admin/custom/publication_form_type_change
//= require rails_admin/custom/check_form_public_fields
//= require rails_admin/custom/related_item_type_change
//= require rails_admin/custom/update_sortable_sort_values
//= require rails_admin/custom/annotate_image
//= require rails_admin/custom/ra.nested-form-hooks
//= require rails_admin/custom/globalize_tabs


// get ckeditor to work nicely with turbolinks
// from: https://github.com/galetahub/ckeditor#turbolink-integration
function set_ckeditor_turbolinks(){
  $('.ckeditor').each(function(){
    CKEDITOR.replace($(this).attr('id'));
  });
}
$(document).ready(set_ckeditor_turbolinks);
$(document).on('page:load', set_ckeditor_turbolinks);

