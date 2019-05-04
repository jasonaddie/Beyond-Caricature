document.addEventListener("turbolinks:load", function() {
  var $filter_selects = $('.filters .filter-select')
  var base_url = [location.protocol, '//', location.host, location.pathname].join('')

  // register all filter selects with select2
  $filter_selects.find('select').select2({
    allowClear: true,
    dropdownAutoWidth: true,
    placeholder: ' '
  })


  // when select filter changes,
  $filter_selects.on('change', 'select', function(){
    var key = $(this).data('key')
    var val = $(this).val()

    var new_search = updateQueryStringParam(document.location.search, key, val)
    // since filter is changing, reset the pagination page number
    if (new_search !== ''){
      new_search = updateQueryStringParam(new_search, 'page', null)
    }

    // load the oage with the updated filters
    window.location = base_url + new_search

  })
})

// taken from: https://gist.github.com/excalq/2961415
var updateQueryStringParam = function (urlQueryString, key, value) {

    var newParam = key + '=' + value,
        params = '?' + newParam;

    // If the "search" string exists, then build params from it
    if (urlQueryString) {
        var updateRegex = new RegExp('([\?&])' + key + '[^&]*');
        var removeRegex = new RegExp('([\?&])' + key + '=[^&;]+[&;]?');

        if( typeof value == 'undefined' || value == null || value == '' ) { // Remove param if value is empty
            params = urlQueryString.replace(removeRegex, "$1");
            params = params.replace( /[&;]$/, "" );

        } else if (urlQueryString.match(updateRegex) !== null) { // If param exists already, update it
            params = urlQueryString.replace(updateRegex, "$1" + newParam);

        } else { // Otherwise, add it to end of query string
            params = urlQueryString + '&' + newParam;
        }
    }

    // no parameter was set so we don't need the question mark
    params = params == '?' ? '' : params;

    return params;
};