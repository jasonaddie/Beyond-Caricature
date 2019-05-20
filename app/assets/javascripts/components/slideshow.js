//= require slick.min

document.addEventListener("turbolinks:load", function() {

  // highlights slideshow
  if (document.querySelector('.slideshow-highlights-slick .slideshow-slides') !== null){
    $('.slideshow-highlights-slick .slideshow-slides').slick({
      autoplay: false,
      autoplaySpeed: 4000,
      variableWidth: false,
      arrows: false,
      dots: true
    });
  }

  // news item slideshow
  if (document.querySelector('.slideshow-news-item-slick .slideshow-slides') !== null){
    $('.slideshow-news-item-slick .slideshow-slides').slick({
      centerMode: true,
      autoplay: true,
      autoplaySpeed: 4000,
      variableWidth: true,
      adaptiveHeight: true,
      arrows: true,
      nextArrow: $('.slick-next'),
      prevArrow: $('.slick-prev')
    });

    // if the news content has the placeholder [slideshow] in it move the slideshow to this spot
    var p = document.querySelectorAll('.news-item-container .news-item-content p')
    for (var i=0;i<p.length;i++){
      if (p[i].textContent.includes('[slideshow]')){
        document.querySelector('.news-item-container .news-item-content').replaceChild(document.querySelector('.slideshow-news-item-slick'), p[i])
        break
      }
    }
  }


});