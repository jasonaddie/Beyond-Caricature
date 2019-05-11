// place annotation markers
document.addEventListener("turbolinks:load", function() {

  if (document.querySelector('body.home.image .modal-annotations') !== null){

    // compute the correct top/left positioning for each marker based on the actuall image size being shown
    function setMarkerPositions(){
      var img = document.querySelector('body.home.image .modal-annotations .annotation-markers img')
      var markers = img.parentElement.querySelectorAll('.annotation-marker')
      var help = img.parentElement.querySelector('.annotation_help')
      var list = img.parentElement.nextElementSibling

      // plaec the markers
      // - account for padding and the help text height
      markers.forEach(function(marker){
        marker.style.left = ((marker.dataset.x * $(img).width()) + convertRemToPixels(0.75)).toFixed(2) + 'px'
        marker.style.top = ((marker.dataset.y * $(img).height()) + convertRemToPixels(0.75) + $(help).height()).toFixed(2) + 'px'
      })

      // set the height of the list if it is longer than the image
      if ($(list).height() > ($(img).height() + $(help).height())){
        list.style.height = (($(img).height() + $(help).height()) * 1.10).toFixed(0) + 'px'
      }else{
        list.style.height = null
      }
    }

    $('body.home.image .modal-annotations').on('opening-modal', setMarkerPositions)
    $(window).on('resize', setMarkerPositions)


    // when click on markers on image, highlight the annotaiton text in the list of text
    document.querySelectorAll('body.home.image .modal-annotations .annotation-markers .annotation-marker').forEach( el => {
      el.addEventListener('click', () => {
        // turn off all highlights
        document.querySelectorAll('body.home.image .modal-annotations .annotation-list li:not([data-number="' + el.dataset.number + '"]) .annotation-text').forEach( t => {
          t.classList.remove('is-active')
        })

        // toggle the selected item
        document.querySelector('body.home.image .modal-annotations .annotation-list li[data-number="' + el.dataset.number + '"] .annotation-text').classList.toggle('is-active')
      })
    })
  }
})

