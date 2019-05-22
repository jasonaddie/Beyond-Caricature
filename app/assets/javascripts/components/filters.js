var dateFormat = 'yy-mm-dd'
var defaultYear = (new Date()).getFullYear()
var defaultMonth = (new Date()).getMonth()
var currentDate = new Date(new Date().setHours(0,0,0,0))
var yearAppStart = 2019
var minDate = yearAppStart.toString() + '-01-01'
var maxDate = new Date((new Date()).getFullYear(), 12, 31)
var yearRange
var defaultDate = new Date()

document.addEventListener("turbolinks:load", function() {
  var $filter_button = $('.filters .filters-button button')
  var $filter_toggle = $('.filters .filter-toggle')
  var $filter_selects = $('.filters .filter-select')
  var $filter_dates = $('.filters .filter-date')
  var $filter_dates_clear = $filter_dates.find('.clear-date')
  var $filter_searches = $('.filters .filter-search')
  var $filter_date_content = $filter_dates.find('.dropdown-trigger-content')
  var $filter_label_date = $('.filters .filter-label-date')
  var is_datepicker_now = $filter_dates.data('options') === 'now'
  var base_url = [location.protocol, '//', location.host, location.pathname].join('')

  // if there is a min value, set it as min date
  if ($filter_date_content.data('min') !== ''){
    minDate = $filter_date_content.data('min')
  }
  // if there is a max value, set it as max date
  if ($filter_date_content.data('max') !== ''){
    maxDate = $filter_date_content.data('max')
  }

  // set the year range
  yearRange = minDate.substring(0,4) + ':' + maxDate.substring(0,4)

  if (!is_datepicker_now){
    var d = $.datepicker.parseDate( dateFormat, minDate)
    defaultYear = d.getFullYear()
    defaultMonth = d.getMonth()
    defaultDate = null
  }

  // register all filter selects with select2
  $filter_selects.find('select').select2({
    allowClear: true,
    dropdownAutoWidth: true,
    placeholder: ' '
  })

  // register all dates with datepicker
  // var date_options = $.extend(true, {}, $.datepicker.regional[$('html').attr('lang')], {
  //   changeMonth: true,
  //   changeYear: true,
  //   dateFormat: dateFormat,
  //   minDate: minDate,
  //   maxDate: maxDate,
  //   yearRange: yearRange
  // }, generate_date_options(is_datepicker_now))
  var date_options = $.extend(true, {}, $.datepicker.regional[$('html').attr('lang')], {
    changeMonth: true,
    changeYear: true,
    dateFormat: dateFormat,
    minDate: minDate,
    maxDate: maxDate,
    yearRange: yearRange
  })

  var date_start = $filter_dates.find('.date-start .datepicker').datepicker(date_options)
    .on("change", function() {
      var d = getDate(this)
      date_end.datepicker( "option", "minDate", d );
      set_datepicker_select_values(date_end, d.getMonth(), d.getFullYear())
    })

  var date_end = $filter_dates.find('.date-end .datepicker').datepicker(date_options)
    .on("change", function() {
      var d = getDate(this)
      date_start.datepicker( "option", "maxDate", d );
      set_datepicker_select_values(date_start, d.getMonth(), d.getFullYear())
    })

  // if there is no date value, preset the calendar to show
  // a specific month and year
  if ($filter_date_content.data('start') === '' && $filter_date_content.data('end') !== ''){
    var d = $.datepicker.parseDate( dateFormat, $filter_date_content.data('end'))
    set_datepicker_select_values(date_start, d.getMonth(), d.getFullYear())
  }else if ($filter_date_content.data('start') === ''){
    set_datepicker_select_values(date_start, defaultMonth, defaultYear)
  }else{
    date_start.datepicker('setDate', $filter_date_content.data('start'))
  }

  if ($filter_date_content.data('start') !== '' && $filter_date_content.data('end') === ''){
    var d = $.datepicker.parseDate( dateFormat, $filter_date_content.data('start'))
    set_datepicker_select_values(date_end, d.getMonth(), d.getFullYear())
  }else if ($filter_date_content.data('end') === ''){
    set_datepicker_select_values(date_end, defaultMonth, defaultYear)
  }else{
    date_end.datepicker('setDate', $filter_date_content.data('end'))
  }

  // when click on date label
  // open datepicker
  $filter_label_date.on('click', function(){
    $(this).siblings('.dropdown').find('.dropdown-trigger .button').trigger('click')
  })

  // when click on 'x' in date label
  // reload page without the date param
  $filter_dates_clear.on('click', function(){
    show_loading_image()
    reload_page_with_new_params({date_start: null, date_end: null})
  })


  // when select filter changes,
  // reload the page
  $filter_selects.on('change', 'select', function(){
    show_loading_image()
    process_filter_request(this)
  })

  // when date filter closes,
  // reload the page
  $filter_dates.on('click', '.button-close', function(){
    show_loading_image()

    var start = formatDate(date_start.datepicker("getDate"))
    var end = formatDate(date_end.datepicker("getDate"))
    var current = formatDate(currentDate)
    var params = {}

    if (start && start !== current){
      params.date_start = start
    }else{
      params.date_start = null
    }
    if (end && end !== current){
      params.date_end = end
    }else{
      params.date_end = null
    }

    // if the values have changed, reload the page
    if ($filter_date_content.length > 0 && (
        (($filter_date_content.data('start') !== '' || params.date_start !== null) &&
          $filter_date_content.data('start') !== params.date_start) ||
        (($filter_date_content.data('end') !== '' || params.date_end !== null) &&
          $filter_date_content.data('end') !== params.date_end)
      )){

      reload_page_with_new_params(params)
    }else{
      // values of not changed - close the dropdown
      $(this).closest('.dropdown').removeClass('is-active')
    }

  })

  // clear the date filter values
  $filter_dates.on('click', '.button-clear', function(){
    date_start.datepicker('setDate', currentDate)
    set_datepicker_select_values(date_start, defaultMonth, defaultYear, true)
    date_end.datepicker('setDate', currentDate)
    set_datepicker_select_values(date_end, defaultMonth, defaultYear, true)
  })

  // when search changes,
  // reload the page
  $filter_searches.on('keyup', 'input', function (e) {
    if (e.keyCode == 13) {
      show_loading_image()
      process_filter_request(this)
    }
  })

  // show/hide filters on mobile
  $filter_button.on('click', function(){
    $filter_toggle.toggleClass('is-hidden-mobile')
  })


  var show_loading_image = function(){
    $('.loading').addClass('is-active')
  }


  var process_filter_request = function(ths){
    var key = $(ths).data('key')
    var val = $(ths).val()
    var options = {}
    options[key] = val

    reload_page_with_new_params(options)
  }

  var reload_page_with_new_params = function(params){
    var new_search = document.location.search;

    $.each( params, function( key, value ) {
      new_search = updateQueryStringParam(new_search, key, value)
    })
    // since filter is changing, reset the pagination page number
    if (new_search !== ''){
      new_search = updateQueryStringParam(new_search, 'page', null)
    }

    // load the page with the updated filters
    window.location = base_url + new_search
  }

  // set the month and year selects in the datepicker if
  // - datepicker value is today's date
  // - or forceSetting = true
  function set_datepicker_select_values(date_obj, month, year, forceSetting){
    if (date_obj.datepicker('getDate').getTime() === currentDate.getTime() || forceSetting === true){
      $(date_obj).find('.ui-datepicker-month').val(month)
      $(date_obj).find('.ui-datepicker-month').trigger('change')
      $(date_obj).find('.ui-datepicker-year').val(year)
      $(date_obj).find('.ui-datepicker-year').trigger('change')
    }
  }

  function generate_date_options(is_datepicker_now){
    options = {}
    if (is_datepicker_now){
      options.minDate = yearAppStart.toString() + '-01-01'
      options.maxDate = new Date((new Date()).getFullYear(), 12, 31)
      options.yearRange = yearAppStart.toString() + ":" + (new Date()).getFullYear()
    }else{
      options.minDate = '1860-01-01'
      options.maxDate = new Date((new Date()).getFullYear(), 12, 31)
      options.yearRange = "1860:" + (new Date()).getFullYear()
    }
    return options
  }

})



// taken from: https://gist.github.com/excalq/2961415
var updateQueryStringParam = function (urlQueryString, key, value) {
  var newParam = key + '=' + value,
      params = '?' + newParam;

  // If the "search" string exists, then build params from it
  if (urlQueryString) {
    var updateRegex = new RegExp('([\?&])' + key + '[^&]*');
    var removeRegex = new RegExp('([\?&])' + key + '=[^&;]+[&;]?');

    if( typeof value === 'undefined' || value === null || value === '' ) { // Remove param if value is empty
      params = urlQueryString.replace(removeRegex, "$1");
      params = params.replace( /[&;]$/, "" );

    } else if (urlQueryString.match(updateRegex) !== null) { // If param exists already, update it
      params = urlQueryString.replace(updateRegex, "$1" + newParam);

    } else { // Otherwise, add it to end of query string
      params = urlQueryString + '&' + newParam;

    }
  }

  // do not include any null values in params
  if (params.slice(-5) === '=null'){
    params = '?'
  }

  // no parameter was set so we don't need the question mark
  params = params === '?' ? '' : params;

  return params;
};

function getDate( element ) {
  var date;
  try {
    date = $.datepicker.parseDate( dateFormat, element.value );
  } catch( error ) {
    date = null;
  }

  return date;
}
