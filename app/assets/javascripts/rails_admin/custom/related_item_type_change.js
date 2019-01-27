function related_item_type_change(){
  // related item nested form
  //  - when select related item type,
  //    show the correct item type to select

  var $item_type = $('form select.related-item-type')
  var fields = {
    'publication': '0',
    'issue': '1',
    'illustration': '2',
    'illustrator': '3'
  }
  var suffix = '_field'

  function update_related_item_field_visibility(select_field){
    // show the field that matches the related item type
    // hide all the rest

    var selected_value = $(select_field).val();
    // only check the fields that are next to the selected field
    var $fieldset = $(select_field).closest('fieldset');

    $.each(fields, function(name, value){
      var $field = $fieldset.find('.' + name + suffix)
      if ($field){
        if (selected_value === value){
          $field.show()
        }else{
          $field.hide()
        }
      }
    })
  }

  // if related item type field exists, register the change event
  if ($item_type){
    $item_type.change(function(){
      update_related_item_field_visibility(this);
    })

    // run when the page loads to properly set
    // view when editing
    // - there can be many so set all properly
    $item_type.each(function(){
      update_related_item_field_visibility(this);
    })
  }
}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ related_item_type_change(); });
