//= require jssor.slider.min
document.addEventListener("turbolinks:load", function() {

  // news item slideshow
  if (document.querySelector('#news-item-slideshow') !== null){
    var options = {
      $AutoPlay: 1,
      $Idle: 5000,
      $FillMode : 1,
      $SlideSpacing: 65,
      $ArrowNavigatorOptions: {
        $Class: $JssorArrowNavigator$
      },
      $BulletNavigatorOptions: {
        $Class: $JssorBulletNavigator$
      }
    }
    var jssor1_slider = new $JssorSlider$("news-item-slideshow", options)

    // if the news content has the placeholder [slideshow] in it move the slideshow to this spot
    var p = document.querySelectorAll('.news-item-container .news-item-content p')
    for (var i=0;i<p.length;i++){
      if (p[i].textContent.includes('[slideshow]')){
        document.querySelector('.news-item-container .news-item-content').replaceChild(document.querySelector('#news-item-slideshow'), p[i])
        break
      }
    }
  }

});