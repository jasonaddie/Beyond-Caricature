function annotate_image(){
  // load the illustration image into the annotation image block

  var $img_container = $('.has_many_association_type .annotation-image')
  var $img = $img_container.find('img')
  var $mask = $('form .mask')

  function reload_vars(){
    $img_container = $('.has_many_association_type .annotation-image')
    $img = $img_container.find('img')
    $mask = $('form .mask')
  }

  //////////////////////////////////////////////////////
  function load_image_preview_into_container(){
    var $img_preview = $('#illustration_image_field .controls img.preview')
    if ($img_preview.length){
      // image exists, load it into the section
      $img_container.empty().append('<img src="' + $img_preview.attr('src') + '" />')
    }
  }

  //////////////////////////////////////////////////////
  function create_marker(x, y, unique_id, marker_number){
    var marker = $('<div class="marker" data-unique-id="' + unique_id + '"><div class="marker-number">' + marker_number + '</div></div>')

    if (x && y){
      marker.css({
        left: x + 'px',
        top: y + 'px'
      })
    }

    return marker
  }

  //////////////////////////////////////////////////////
  // if there are annotations on record,
  // add the markers on the image and in each tab pane
  this.add_markers = function(){
    var $tab_panes = $('.tab-content.annotations > .fields.tab-pane')
    var $existing_markers = $img_container.find('.marker')
    var img_width = $img.width()
    var img_height = $img.height()
    var x, y, unique_id;

    // only add markers if annotations exist and markers are not already loaded
    if ($tab_panes.length && !$existing_markers.length){
      // annotation exist, add markers
      $tab_panes.each(function(index){
        // get values
        x_percent = $(this).find('.hidden-input-x').val()
        y_percent = $(this).find('.hidden-input-y').val()

        if (x_percent.length > 0 && y_percent.length > 0){
          x = (x_percent * img_width).toFixed(2)
          y = (y_percent * img_height).toFixed(2)
          unique_id = $(this).attr('id')

          // add to image
          $img_container.append(
            create_marker(x, y, unique_id, index+1)
          );

          // add to tab pane
          var $btn = $(this).find('.annotation-add')
          create_marker(null, null, unique_id, index+1).insertAfter($btn)
        }
      });
    }
  }

  //////////////////////////////////////////////////////
  // delete all markers on the image and in the tab panes
  this.remove_markers = function(){
    $('.tab-content.annotations > .fields.tab-pane > .marker').remove()
    $img_container.find('.marker').remove()
  }


  //////////////////////////////////////////////////////
  //////////////////////////////////////////////////////


  //////////////////////////////////////////////////////
  // when annotation is added
  // - show image section
  // - if image is not in section, load it
  // this event is the same event that is called via nested form hooks
  //  https://github.com/sferik/rails_admin/blob/master/app/assets/javascripts/rails_admin/ra.nested-form-hooks.coffee
  $(document).on('nested:fieldAdded', 'form .has_many_association_type.illustration_annotations_field', function(content){
    reload_vars()

    // check if image is in section, if not load it
    if (!$img.length){
      // no image, see if one exists
      load_image_preview_into_container();
    }

    // show the image section
    $img_container.select(':hidden').show('slow', function(){
      // now that the image is loaded, show the markers
      add_markers();
    })

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


  //////////////////////////////////////////////////////
  // when the illustration image changes, update the image in the annotations
  // - this change event is the same change event that is triggered when an image
  //   is loaded and the preview is generated
  //   https://github.com/sferik/rails_admin/blob/master/app/assets/javascripts/rails_admin/ra.widgets.coffee
  $('form input#illustration_image[data-fileupload]').on('change', function(){
    // the image is changed

    reload_vars()

    // hide any image already there
    $img.fadeOut('slow')

    // to be safe, let's wait for the image to be uploaded and preview created
    // before loading it in annotation section
    setTimeout(function() {
      load_image_preview_into_container();
    }, 2000);
  })


  //////////////////////////////////////////////////////
  // turn on ability to add marker to image
  $('.tab-content.annotations').on('click', '.annotation-add', function() {
    reload_vars()
    var $tab_pane = $(this).closest('.fields.tab-pane')
    var unique_id = $tab_pane.attr('id')
    var index = $(this).closest('.tab-content').find('> .fields.tab-pane').index($tab_pane)

    $img.data('marker-number', index + 1)
    $img.data('unique-id', unique_id)
    $img.addClass('marking')

    // if marker for this annotation already exists, hide it
    $img_container.find('.marker[data-unique-id="' + unique_id + '"]').addClass('updating');

    // turn on mask
    $mask.addClass('active');

  });


  //////////////////////////////////////////////////////
  // add a marker to the image
  $img_container.on('click', 'img.marking', function (e) {
    reload_vars()
    var marker_number = $(this).data('marker-number')
    var unique_id = $(this).data('unique-id')
    var $tab_pane = $('#' + unique_id)
    var x = e.offsetX - 12
    var y = e.offsetY - 12

    // add marker
    // - marker is 24x24 so to center marker on where the
    //   mouse was clicked, subtract 12 from the offset
    $img_container.append(
      create_marker(x, y, unique_id, marker_number)
    );

    // add marker to the nested field
    var $btn = $tab_pane.find('.annotation-add')
    create_marker(null, null, unique_id, marker_number).insertAfter($btn)

    // add x and y value to the hidden field
    // - convert to percents
    $tab_pane.find('.hidden-input-x').val((x / $img.width()).toFixed(4))
    $tab_pane.find('.hidden-input-y').val((y / $img.height()).toFixed(4))

    // remove any existing marker
    $img_container.find('.marker.updating').remove();

    // turn off ability to add marker
    $img.removeClass('marking');

    // turn off mask
    $mask.removeClass('active');
  });


  //////////////////////////////////////////////////////
  // if mask is on and user clicks on it, turn mask off
  $('form').on('click', '.mask', function(){
    reload_vars()

    // if there is an existing marker, show it again
    $img_container.find('.marker.updating').removeClass('updating')

    // hide the mask
    $(this).removeClass('active')
  })

  //////////////////////////////////////////////////////
  // on page load, if this is illustration form
  // add mask div
  if ($img_container.length){
    $('form').append('<div class="mask"></div>')
    $('form').addClass('has-mask')
  }


}

// call functions when rails admin page loads
$(document).on('rails_admin.dom_ready', function(){ annotate_image(); });
