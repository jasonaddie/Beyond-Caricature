// new globalize tabs have a temp placeholder id that needs to be replaced
// - this temp placeholder id exists because it is necessary to work in nested forms
function initialize_globalize_tabs(){
  var placeholder = '[temp-id-placeholder]'
  var temp_id = new Date().getTime().toString()

  // replace the nav tab reference
  $('.nav.globalize-tabs li a[data-target*="' + placeholder + '"]').each(function(i, element){
    $(element).data('target', $(element).data('target').replace(placeholder, temp_id))
  })

  // replace the tab-panel reference
  $('.tab-content.globalize-tab-content .tab-pane').each(function(i, element){
    // if class has the placeholder name, update it
    var cls = null
    element.classList.forEach(function(class_name){
      if (cls == null && class_name.includes(placeholder)){
        cls = class_name
      }
    })

    // update the class name
    if (cls){
      $(element).addClass(cls.replace(placeholder, temp_id)).removeClass(cls)
    }
  })
}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ initialize_globalize_tabs(); });

