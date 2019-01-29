function annotate_image(){
  // load the illustration image into the annotation image block

  var $img_container = $('.has_many_association_type .annotation-image')

  function load_image_preview_into_container(){
    var $img = $('#illustration_image_field .controls img.preview')
    if ($img.length){
      // image exists, load it into the section
      $img_container.empty().append('<img src="' + $img.attr('src') + '" />')
    }
  }

  // when annotation is added
  // - show image section
  // - if image is not in section, load it
  // this event is the same event that is called via nested form hooks
  //  https://github.com/sferik/rails_admin/blob/master/app/assets/javascripts/rails_admin/ra.nested-form-hooks.coffee
  $(document).on('nested:fieldAdded', 'form .has_many_association_type.illustration_annotations_field', function(content){

    // check if image is in section, if not load it
    if (!$img_container.find('img').length){
      // no image, see if one exists
      load_image_preview_into_container();
    }

    // show the image section
    $('.has_many_association_type .annotation-image').select(':hidden').show('slow')
  });


  // when the illustration image changes, update the image in the annotations
  // - this change event is the same change event that is triggered when an image
  //   is loaded and the preview is generated
  //   https://github.com/sferik/rails_admin/blob/master/app/assets/javascripts/rails_admin/ra.widgets.coffee
  $('form input#illustration_image[data-fileupload]').on('change', function(){
    // the image is changed

    // hide any image already there
    $img_container.find('img').fadeOut('slow')

    // to be safe, let's wait for the image to be uploaded and preview created
    // before loading it in annotation section
    setTimeout(function() {
      load_image_preview_into_container();
    }, 2000);
  })

}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ annotate_image(); });
