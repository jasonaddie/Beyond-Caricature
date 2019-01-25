//= require rails_admin/themes/material/ui.js
//= require ckeditor/init
//= require rails_admin/custom/ckeditor_ajax

function check_form_public_fields(){
  // for forms with globalize tabs and is_public field
  // update validation status of each language for making public
  // when filling out form

  // if this form has has_public fields, then enable the change event
  var form_translations = 'form > fieldset > .globalize_tabs_type';
  var $public_fields = $(form_translations + ' > .globalize-tab-content input[type="checkbox"].is-public-field');
  var $tab_panes = $(form_translations + ' > .globalize-tab-content > .tab-pane');
  var $has_many = $('form > fieldset > .has_many_association_type');
  var $has_many_tab_panes = $has_many.find('> .tab-content > .tab-pane');
  var required_help_text = $('ul.globalize-tabs').data('help-text');
  var validation_error_help_text = $('ul.globalize-tabs').data('required-text');
  var validation_error_html = '<span class="required-for-public-validation-indicator" title="' + validation_error_help_text + '">***</span>';

  // fields changed value, check validation status if is_public is checked
  function check_if_valid(){
    check_if_translations_valid();

    check_if_has_many_translations_valid();
  }

  function check_if_translations_valid(){
    $(form_translations + ' > .controls > ul.globalize-tabs li').each(function(index, $li){
      var current_pane = $tab_panes[index];

      // see if the is_public checkbox at this index is checked
      if ($($public_fields[index]).is(':checked')){
        // is public is checked
        // check that all the required fields for publishing have values
        var is_fields_provided = [];

        // look for items in the current translation pane
        $(current_pane).find(':input').each(function(){
          if ($(this).parent().find('.help-block').text() === required_help_text){
            // this is a required block
            // check its value

            // if ckeditor field
            if ($(this).hasClass('ckeditored')){
              is_fields_provided.push(CKEDITOR.instances[$(this).attr('id')].getData() !== '');

            }else{
              is_fields_provided.push($(this).val() !== '')
            }
          }
        })

        // indicate whether or not the translation tab is valid
        if (is_fields_provided.indexOf(false) === -1){
          $($li).find('a span.required-for-public-validation-indicator').remove();
          $(current_pane).removeClass('invalid');
        }
        else{
          // only insert span if it is not there yet
          if ($($li).find('a span.required-for-public-validation-indicator').length === 0){
            $($li).find('a').prepend(validation_error_html);
          }
          $(current_pane).addClass('invalid');
        }

      }else {
        // is public is not checked
        // so turn off validation error indicators
        $($li).find('a span.required-for-public-validation-indicator').remove();
        $(current_pane).removeClass('invalid');
      }
    });
  }

  function check_if_has_many_translations_valid(){
    var is_fields_provided_has_many = {};

    // if there is a has many association
    // and it is visible check its fields too

    if ($has_many && $has_many.is(':visible')){
      // go through each has many panes
      $($has_many).find(' > .controls > ul li').each(function(has_many_index, $has_many_li){

        var has_many_current_pane = $has_many_tab_panes[has_many_index];
        var has_many_current_pane_id = $(has_many_current_pane).attr('id');
        is_fields_provided_has_many[has_many_current_pane_id] = {};

        // go through each locale tab
        var $has_many_current_with_translations = $(has_many_current_pane).find('fieldset > .globalize_tabs_type');
        var $has_many_current_tab_panes = $(has_many_current_pane).find('.globalize-tab-content > .tab-pane');

        $has_many_current_with_translations.find(' > .controls > ul.globalize-tabs li').each(function(locale_index, $locale_li){
          is_fields_provided_has_many[has_many_current_pane_id][locale_index] = [];
          var locale_current_pane = $has_many_current_tab_panes[locale_index];

          // see if the is_public checkbox at this index is checked
          if ($($public_fields[locale_index]).is(':checked')){

            var is_fields_provided = [];

            // go through each inputs
            $(locale_current_pane).find(':input').each(function(){
              if ($(this).parent().find('.help-block').text() === required_help_text){
                // this is a required block
                // check its value

                // if ckeditor field
                if ($(this).hasClass('ckeditored')){
                  is_fields_provided_has_many[has_many_current_pane_id][locale_index].push(CKEDITOR.instances[$(this).attr('id')].getData() !== '');

                }else{
                  is_fields_provided_has_many[has_many_current_pane_id][locale_index].push($(this).val() !== '')
                }
              }
            })

            // indicate whether or not the locale tab is valid
            if (is_fields_provided_has_many[has_many_current_pane_id][locale_index].indexOf(false) === -1){
              $($locale_li).find('a span.required-for-public-validation-indicator').remove();
              $(locale_current_pane).removeClass('invalid');
            }
            else{
              // only insert span if it is not there yet
              if ($($locale_li).find('a span.required-for-public-validation-indicator').length === 0){
                $($locale_li).find('a').prepend(validation_error_html);
              }
              $(locale_current_pane).addClass('invalid');
            }

          }else {
            // is public is not checked
            // so turn off validation error indicators
            $($locale_li).find('a span.required-for-public-validation-indicator').remove();
            $(locale_current_pane).removeClass('invalid');
          }
        });

        // indicate whether or not the has many tab is valid
        if (Object.values(is_fields_provided_has_many[has_many_current_pane_id]).flat().indexOf(false) === -1){
          $($has_many_li).find('a span.required-for-public-validation-indicator').remove();
          $(has_many_current_pane).removeClass('invalid');
        }
        else{
          // only insert span if it is not there yet
          if ($($has_many_li).find('a span.required-for-public-validation-indicator').length === 0){
            $($has_many_li).find('a').prepend(validation_error_html);
          }
          $(has_many_current_pane).addClass('invalid');
        }

      });
    }
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
$(document).on('rails_admin.dom_ready', function(){ check_form_public_fields(); });
$(document).on('rails_admin.dom_ready', function(){ publication_form_type_change(); });

////////////////////////////////////
////////////////////////////////////
////////////////////////////////////


// get ckeditor to work nicely with turbolinks
// from: https://github.com/galetahub/ckeditor#turbolink-integration
function set_ckeditor_turbolinks(){
  $('.ckeditor').each(function(){
    CKEDITOR.replace($(this).attr('id'));
  });
}
$(document).ready(set_ckeditor_turbolinks);
$(document).on('page:load', set_ckeditor_turbolinks);



////////////////////////////////////
////////////////////////////////////
////////////////////////////////////

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




//
$(document).on('rails_admin.dom_ready', function(){
  $('.tab-content.sort-items').sortable({
    containment: "parent",
    // update all of the sort values with the new order
    update: function(e,ui){
      // get all sort inputs and then update the value
      var $inputs = $(ui.item).closest('.tab-content.sort-items').find('input.sort-hidden-input');
      $inputs.each(function(index){
        $(this).val(index);
      })
    }
  });
});
