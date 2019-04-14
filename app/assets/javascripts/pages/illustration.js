document.addEventListener("turbolinks:load", function() {

  // register click events for annotation modal
  if (document.querySelector('body.home.illustration .modal-annotations') !== null){

    // when click on markers on image, highlight the annotaiton text in the list of text
    document.querySelectorAll('body.home.illustration .modal-annotations .annotation-markers .annotation-marker').forEach( el => {
      el.addEventListener('click', () => {
        // turn off all highlights
        document.querySelectorAll('body.home.illustration .modal-annotations .annotation-list li:not([data-number="' + el.dataset.number + '"]) .annotation-text').forEach( t => {
          t.classList.remove('is-active')
        })

        // toggle the selected item
        document.querySelector('body.home.illustration .modal-annotations .annotation-list li[data-number="' + el.dataset.number + '"] .annotation-text').classList.toggle('is-active')
      })
    })
  }
})

