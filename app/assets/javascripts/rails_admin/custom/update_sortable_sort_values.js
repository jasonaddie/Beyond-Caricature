function update_sortable_sort_values(sort_items){
  // get all sort inputs and then update the value
  // var $tab_content = $(item).closest('.tab-content.sort-items');
  var $inputs = $(sort_items).find('input.hidden-input-sort');
  $inputs.each(function(index){
    $(this).val(index);
  })

  // if this is annotations, also update the narker numbers
  var annotate_imgs = new annotate_image();
  annotate_imgs.remove_markers();
  annotate_imgs.add_markers();
}
function apply_sorting(){
  // use jquery ui sortable in a nested form
  // and when sorting is done, update the input value for sort fields

  $('.tab-content.sort-items').sortable({
    containment: "parent",
    // update all of the sort values with the new order
    update: function(e,ui){
      update_sortable_sort_values($(ui.item).closest('.tab-content.sort-items'));
    }
  });
}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ apply_sorting(); });
