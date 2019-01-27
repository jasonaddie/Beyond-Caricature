function publication_form_type_change(){
  // on the publication form,
  // when the publication type changes,
  // show the fields that are necessary for
  // the selected type

  var $pub_type = $('form select.publication-type')
  var fields = [
    'publication-publication-editors',
    'publication-editor',
    'publication-publisher',
    'publication-writer',
    'publication-year',
    'publication-file'
  ]
  var type_field_pairings = {
    // journal
    '0': [
      'publication-publication-editors'
    ],

    // book
    '1': [
      'publication-editor',
      'publication-publisher',
      'publication-writer',
      'publication-year',
      'publication-file'
    ],

    // originals
    '2': [
      'publication-year',
      'publication-file'
    ],
  }

  function update_publication_form_field_visibility(){
    // turn on fields that are listed in type_field_pairings
    // all other fields in fields are turned off
    var $form = $('form')
    var fields_to_show = type_field_pairings[$pub_type.val()]
    $.each(fields, function(i, field){
      var $field = $form.find('.' + field)
      if ($field){
        if (fields_to_show === undefined || fields_to_show.indexOf(field) === -1){
          $field.hide()
        }else{
          $field.show()
        }
      }
    })
  }

  // if publicaiton type field exists, register the change event
  if ($pub_type){
    $pub_type.change(function(){
      update_publication_form_field_visibility();
    })

    // run when the page loads to properly set
    // view when editing
    update_publication_form_field_visibility();

  }
}


// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ publication_form_type_change(); });
