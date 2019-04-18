

document.addEventListener("turbolinks:load", function() {

  function checkPortraitMetaTextOverflow() {
    // console.log('=======')
    // console.log('checkPortraitMetaTextOverflow')

    var container = document.querySelector('body.meta-details-container .meta-details.portrait')

    if (container !== null){
      var img = container.querySelector('.meta-image img')
      var title = container.querySelector('h1.title')
      var list = container.querySelector('.meta-items-list')
      var text = container.querySelector('.meta-text')
      var more = container.querySelector('.meta-text-more')
      var more_modal = document.querySelector('body.meta-details-container .modal-meta-text')
      var meta_height = title.scrollHeight + list.scrollHeight + text.scrollHeight

      // console.log(img.scrollHeight)
      // console.log(title.scrollHeight)
      // console.log(list.scrollHeight)
      // console.log(text.scrollHeight)
      // console.log(meta_height)
      // console.log(img.scrollHeight - (meta_height - text.scrollHeight))
      // console.log('==')
      if (meta_height > img.scrollHeight){
        // set text height to match img height
        // console.log('- need to adjust')
        text.style.height = (img.scrollHeight - (meta_height - text.scrollHeight) - title.scrollHeight - 50 - 30) + 'px'
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
  $(window).on('resize', debounce(checkPortraitMetaTextOverflow, 250))
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

      // console.log(text.style.height)
      // console.log(li_height)
      // console.log(text.scrollHeight)
      // console.log('==')
      if (text.scrollHeight > li_height){
        // set text height to match img height
        // console.log('- need to adjust')
        var new_height = li_height - 50
        // console.log(new_height)
        if (new_height < 200){
          // must be at least 200px hight
          new_height = 200
        }
        text.style.height = new_height + 'px'
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
  $(window).on('resize', debounce(checkLandscapeMetaTextOverflow, 250))
  checkLandscapeMetaTextOverflow()


})

