

document.addEventListener("turbolinks:load", function() {

  function checkPersonBioOverflow() {
    console.log('=======')
    console.log('checkPersonBioOverflow')

    var container = document.querySelector('body.home.person .person-details.portrait')

    if (container !== null){
      var img = container.querySelector('.person-image img')
      var title = container.querySelector('h1.title')
      var meta_internal = container.querySelector('.person-meta-details')
      var bio = container.querySelector('.person-bio')
      var more = container.querySelector('.person-bio-more')
      var more_modal = document.querySelector('body.home.person .modal-person-bio')


      if (meta_internal.scrollHeight > img.scrollHeight){
        // set bio height to match img height
        // console.log('- need to adjust')
        // console.log(bio.style.height)
        // console.log(img.scrollHeight)
        // console.log(meta.scrollHeight)
        // console.log(bio.scrollHeight)
        // console.log(img.scrollHeight - (meta.scrollHeight - bio.scrollHeight))
        // console.log('==')
        bio.style.height = (img.scrollHeight - (meta_internal.scrollHeight - bio.scrollHeight) - title.scrollHeight - 50 - 30) + 'px'
        // console.log('-')
        // console.log(bio.style.height)

        // if the bio text is overflown, show the view more link
        if (isVerticalOverflown(bio)){
          more.classList.add('is-active')
        }else{
          more.classList.remove('is-active')
        }

      }
    }
  }

  // window.addEventListener("resize", checkPersonBioOverflow)
  // $(window).on('resize', checkPersonBioOverflow)

  $('body.home.person .person-details.portrait .person-image img').on('load', checkPersonBioOverflow)

})

