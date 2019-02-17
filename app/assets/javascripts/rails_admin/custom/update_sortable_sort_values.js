function update_sortable_sort_values(){
  // use jquery ui sortable in a nested form
  // and when sorting is done, update the input value for sort fields

  $('.tab-content.sort-items').sortable({
    containment: "parent",
    // update all of the sort values with the new order
    update: function(e,ui){
      // get all sort inputs and then update the value
      var $tab_content = $(ui.item).closest('.tab-content.sort-items');
      var $inputs = $tab_content.find('input.hidden-input-sort');
      $inputs.each(function(index){
        $(this).val(index);
      })

      // if this is annotations, also update the narker numbers
      var annotate_imgs = new annotate_image();
      annotate_imgs.remove_markers();
      annotate_imgs.add_markers();
    }
  });
}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ update_sortable_sort_values(); });

  //////////////////////////////////////////////////////
  //////////////////////////////////////////////////////


  //////////////////////////////////////////////////////
  // when item is added
  // - update globalize data target temp-id-placeholder
  // this event is the same event that is called via nested form hooks
  //  https://github.com/sferik/rails_admin/blob/master/app/assets/javascripts/rails_admin/ra.nested-form-hooks.coffee
  $(document).on('nested:fieldAdded', 'form .has_many_association_type.publication-publication-editors', function(content){
    // update temp-id-placeholder with real number
    // need to replace in each tab and each tab-pane
    var placeholder = '[temp-id-placeholder]';
    var temp_id = new Date().getTime().toString();
    $(content.field).find('.controls .nav li a').each(function(){
      $(this).data('target', $(this).data('target').replace(placeholder, temp_id))
    })
    $(content.field).find('.tab-content .tab-pane').each(function(){
      // find the class
      var cls;
      this.classList.forEach(function(value) {
        if (cls === undefined && value.includes(placeholder)){
          cls = value;
        }
      });

      // update the class name
      if (cls){
        // $(this).toggleClass("'" + cls + " " + cls.replace(placeholder, temp_id) + "'")
        $(this).addClass(cls.replace(placeholder, temp_id)).removeClass(cls)
      }
    })
  });
