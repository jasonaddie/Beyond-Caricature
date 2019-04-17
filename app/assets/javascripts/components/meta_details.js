

document.addEventListener("turbolinks:load", function() {

  function checkPortraitMetaTextOverflow() {
    // console.log('=======')
    // console.log('checkPortraitMetaTextOverflow')

    var container = document.querySelector('body.meta-details-container .meta-details.portrait')

    if (container !== null){
      var img = container.querySelector('.meta-image img')
      var title = container.querySelector('h1.title')
      var meta_internal = container.querySelector('.meta-items-details')
      var text = container.querySelector('.meta-text')
      var more = container.querySelector('.meta-text-more')
      var more_modal = document.querySelector('body.meta-details-container .modal-meta-text')


      if (meta_internal.scrollHeight > img.scrollHeight){
        // set text height to match img height
        // console.log('- need to adjust')
        // console.log(text.style.height)
        // console.log(img.scrollHeight)
        // console.log(meta.scrollHeight)
        // console.log(text.scrollHeight)
        // console.log(img.scrollHeight - (meta.scrollHeight - text.scrollHeight))
        // console.log('==')
        text.style.height = (img.scrollHeight - (meta_internal.scrollHeight - text.scrollHeight) - title.scrollHeight - 50 - 30) + 'px'
        // console.log('-')
        // console.log(text.style.height)

        // if the text is overflown, show the view more link
        if (isVerticalOverflown(text)){
          more.classList.add('is-active')
        }else{
          more.classList.remove('is-active')
        }

      }
    }
  }

  // window.addEventListener("resize", checkPortraitMetaTextOverflow)
  // $(window).on('resize', checkPortraitMetaTextOverflow)

  $('body.meta-details-container .meta-details.portrait .meta-image img').on('load', checkPortraitMetaTextOverflow)



  function checkLandscapeMetaTextOverflow() {
    // console.log('=======')
    // console.log('checkLandscapeMetaTextOverflow')

    var container = document.querySelector('body.meta-details-container .meta-details.landscape')

    if (container !== null){
      var meta_list_lis = container.querySelectorAll('.meta-items-list > li')
      var text = container.querySelector('.meta-text')
      var more = container.querySelector('.meta-text-more')
      var more_modal = document.querySelector('body.meta-details-container .modal-meta-text')
      var li_height = 0

      // sum up the li heights
      meta_list_lis.forEach(function(li){
        li_height += li.scrollHeight
      })

      if (text.scrollHeight > li_height){
        // set text height to match img height
        // console.log('- need to adjust')
        // console.log(text.style.height)
        // console.log(img.scrollHeight)
        // console.log(meta.scrollHeight)
        // console.log(text.scrollHeight)
        // console.log(img.scrollHeight - (meta.scrollHeight - text.scrollHeight))
        // console.log('==')
        text.style.height = (li_height - 50 - 30) + 'px'
        // console.log('-')
        // console.log(text.style.height)

        // if the text is overflown, show the view more link
        if (isVerticalOverflown(text)){
          more.classList.add('is-active')
        }else{
          more.classList.remove('is-active')
        }

      }
    }
  }

  // window.addEventListener("resize", checkLandscapeMetaTextOverflow)
  // $(window).on('resize', checkLandscapeMetaTextOverflow)
  checkLandscapeMetaTextOverflow()


})

