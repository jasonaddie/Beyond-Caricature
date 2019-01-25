# this is need so ckeditor in modal updates the textarea value before form is submitted
# taken from: https://github.com/sferik/rails_admin/wiki/CKEditor
$(document).ready ->
  $(document).on 'mousedown', '.save-action', (e) -> # triggers also when submitting form with enter
    for instance of CKEDITOR.instances
      editor = CKEDITOR.instances[instance]
      if editor.checkDirty()
        editor.updateElement();
    return true;