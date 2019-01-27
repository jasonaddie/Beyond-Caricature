function update_sortable_sort_values(){
  // use jquery ui sortable in a nested form
  // and when sorting is done, update the input value for sort fields

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
}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ update_sortable_sort_values(); });
