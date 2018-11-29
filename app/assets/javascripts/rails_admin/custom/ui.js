function check_form_public_fields(){
  // for forms with globalize tabs and is_public field
  // update validation status of each language for making public
  // when filling out form

  // if this form has has_public fields, then enable the change event
  var $public_fields = $('form .globalize-tab-content input[type="checkbox"].is-public-field');
  var $tab_panes = $('form .globalize-tab-content .tab-pane');
  var required_help_text = $('ul.globalize-tabs').data('help-text');

  function check_if_valid(){

    // fields changed value, check validation status if is_public is checked
    $('ul.globalize-tabs li').each(function(index, $li){
      var current_pane = $tab_panes[index];

      // see if the is_public checkbox at this index is checked
      if ($($public_fields[index]).is(':checked')){
        // is public is checked
        // check that all the required fields for publishing have values
        var is_fields_provided = [];

        $(current_pane).find(':input').each(function(){
          if ($(this).parent().find('.help-block').text() === required_help_text){
            // this is a required block
            // check its value
            if ($(this).hasClass('ckeditored')){
              is_fields_provided.push(CKEDITOR.instances[$(this).attr('id')].getData() !== '');
            }else{
              is_fields_provided.push($(this).val() !== '')
            }
          }
        })

        $($li).find('a span').each(function(){
          if (is_fields_provided.indexOf(false) === -1){
            $(this).removeClass('active');
            $(current_pane).removeClass('invalid');
          }
          else{
            $(this).addClass('active');
            $(current_pane).addClass('invalid');
          }
        });

      }else {
        // is public is not checked
        // so turn off validation error indicators
        $($li).find('a span').each(function(){
          $(this).removeClass('active');
          $(current_pane).removeClass('invalid');
        });
      }
    });
  }

  if ($public_fields.length > 0){
    // register form fields
    $('form .globalize-tab-content :input').blur(function(){
      check_if_valid();
    });

    // register ckeditor fields
    var waitCKEDITOR = setInterval(function() {
      if (window.CKEDITOR) {
       clearInterval(waitCKEDITOR);
        for (var i in CKEDITOR.instances) {
          CKEDITOR.instances[i].on('blur', function() {
            check_if_valid();
          });
        }
      }
    }, 100);

    // check if fields valid when page loads
    check_if_valid();
  }
}





function publication_form_type_change(){
  // on the publication form,
  // when the publication type changes,
  // show the fields that are necessary for
  // the selected type

  var $pub_type = $('form select.publication-type')
  var fields = [
    'publication-editor',
    'publication-publisher',
    'publication-writer',
    'publication-file',
    'publication-date',
    'publication-year-start',
    'publication-year-end'
  ]
  var type_field_pairings = {
    // journal
    '0': [
      'publication-editor',
      'publication-publisher',
      'publication-date'
    ],

    // book
    '1': [
      'publication-editor',
      'publication-publisher',
      'publication-writer',
      'publication-file',
      'publication-year-start'
    ],

    // originals
    '2': [
      'publication-file',
      'publication-year-start'
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
$(document).on('rails_admin.dom_ready', function(){ check_form_public_fields(); });
$(document).on('rails_admin.dom_ready', function(){ publication_form_type_change(); });
