var dateFormat = 'yy-mm-dd'
var defaultYear = (new Date()).getFullYear()
var defaultMonth = (new Date()).getMonth()
var yearAppStart = 2019
var defaultMinDate = yearAppStart.toString() + '-01-01'
var defaultMaxDate = new Date((new Date()).getFullYear(), 12, 31)
var yearRange, minDate, maxDate
var defaultDate = null

document.addEventListener("turbolinks:load", function() {
  var $filter_button = $('.filters .filters-button button')
  var $filter_toggle = $('.filters .filter-toggle')
  var $filter_selects = $('.filters .filter-select')
  var $filter_dates = $('.filters .filter-date')
  var $filter_dates_clear = $filter_dates.find('.clear-date')
  var $filter_searches = $('.filters .filter-search')
  var $filter_searches_clear = $filter_searches.find('.clear-search')
  var $filter_date_content = $filter_dates.find('.dropdown-trigger-content')
  var $filter_label_date = $('.filters .filter-label-date')
  var is_datepicker_now = $filter_dates.data('options') === 'now'
  var base_url = [location.protocol, '//', location.host, location.pathname].join('')
  ////////////////////////////////////////////
  // DATES
  ////////////////////////////////////////////
  // if there is a min value, set it as min date
  if ($filter_dates.length >  0){
    if ($filter_date_content.data('min') !== ''){
      minDate = $filter_date_content.data('min')
    }else{
      minDate = defaultMinDate
    }
    // if there is a max value, set it as max date
    if ($filter_date_content.data('max') !== ''){
      maxDate = $filter_date_content.data('max')
    }else{
      maxDate = defaultMaxDate
    }

    // set the year range
    yearRange = minDate.substring(0,4) + ':' + maxDate.substring(0,4)

    var default_date = minDate
    if (is_datepicker_now){
      default_date = maxDate
    }
    var d = $.datepicker.parseDate( dateFormat, default_date)
    defaultYear = d.getFullYear()
    defaultMonth = d.getMonth()

    // register all dates with datepicker
    var date_options = $.extend(true, {}, $.datepicker.regional[$('html').attr('lang')], {
      changeMonth: true,
      changeYear: true,
      dateFormat: dateFormat,
      minDate: minDate,
      maxDate: maxDate,
      yearRange: yearRange,
      defaultDate: null
    })

    // when change one dates, update the min/max of the other
    var date_start = $filter_dates.find('.date-start .datepicker').datepicker(date_options)
      .on("change", function() {
        var d = getDate(this)
        if (d !== null){
          // update end date min date
          var end = date_end.datepicker("getDate")
          date_end.datepicker( "option", "minDate", d );
          if (end < d || end === null){
            // end is less than the new start date, so reset end to null
            reset_date(date_end)
            set_datepicker_select_values(date_end, d.getMonth(), d.getFullYear())
          }

          // update selected date label
          $(this).parent().find('.selected-date-label').text(formatDate(d))
        }else{
          // update selected date label
          $(this).parent().find('.selected-date-label').text($(this).parent().find('.selected-date-label').data('no-data'))
        }
      })

    var date_end = $filter_dates.find('.date-end .datepicker').datepicker(date_options)
      .on("change", function() {
        var d = getDate(this)
        if (d !== null){
          // update start date max date
          var start = date_start.datepicker("getDate")
          date_start.datepicker( "option", "maxDate", d );
          if (start > d || start === null){
            // start is greater than the new end date, so reset start to null
            reset_date(date_start)
            set_datepicker_select_values(date_start, d.getMonth(), d.getFullYear())
          }

          // update selected date label
          $(this).parent().find('.selected-date-label').text(formatDate(d))
        }else{
          // update selected date label
          $(this).parent().find('.selected-date-label').text($(this).parent().find('.selected-date-label').data('no-data'))
        }
      })

    // if there is no date value, preset the calendar to show
    // a specific month and year
    if ($filter_date_content.data('start') === '' && $filter_date_content.data('end') !== ''){
      var d = $.datepicker.parseDate( dateFormat, $filter_date_content.data('end'))
      reset_date(date_start)
      set_datepicker_select_values(date_start, d.getMonth(), d.getFullYear())
    }else if ($filter_date_content.data('start') === ''){
      reset_date(date_start)
      set_datepicker_select_values(date_start, defaultMonth, defaultYear)
    }else{
      date_start.datepicker('setDate', $filter_date_content.data('start'))
    }

    if ($filter_date_content.data('start') !== '' && $filter_date_content.data('end') === ''){
      var d = $.datepicker.parseDate( dateFormat, $filter_date_content.data('start'))
      reset_date(date_end)
      set_datepicker_select_values(date_end, d.getMonth(), d.getFullYear())
    }else if ($filter_date_content.data('end') === ''){
      reset_date(date_end)
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
      toggle_loading_image()
      reload_page_with_new_params({date_start: null, date_end: null})
    })

    // when date filter closes,
    // reload the page
    $filter_dates.on('click', '.button-close', function(){
      toggle_loading_image()

      var start = formatDate(date_start.datepicker("getDate"))
      var end = formatDate(date_end.datepicker("getDate"))
      var params = {date_start: start, date_end: end}

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
    // and reset the min/max values
    $filter_dates.on('click', '.button-clear', function(){
      reset_date(date_end)
      date_end.datepicker( "option", {minDate: minDate, maxDate: maxDate} )
      set_datepicker_select_values(date_end, defaultMonth, defaultYear, true)
      date_end.parent().find('.selected-date-label').text(date_end.parent().find('.selected-date-label').data('no-data'))
      reset_calendar_selections(date_end)

      reset_date(date_start)
      date_start.datepicker( "option", {minDate: minDate, maxDate: maxDate} )
      set_datepicker_select_values(date_start, defaultMonth, defaultYear, true)
      date_start.parent().find('.selected-date-label').text(date_start.parent().find('.selected-date-label').data('no-data'))
      reset_calendar_selections(date_start)
    })
  }

  ////////////////////////////////////////////
  // SELECTS
  ////////////////////////////////////////////
  // register all filter selects with select2
  $filter_selects.find('select').select2({
    allowClear: true,
    dropdownAutoWidth: true,
    placeholder: ' '
  })

  // when select filter changes,
  // reload the page
  $filter_selects.on('change', 'select', function(){
    toggle_loading_image()
    process_filter_request(this)
  })


  ////////////////////////////////////////////
  // SEARCH
  ////////////////////////////////////////////
  // when search changes,
  // reload the page
  $filter_searches.on('keyup', 'input', function (e) {
    if (e.keyCode == 13) {
      toggle_loading_image()
      process_filter_request(this)
    }else {
      if (this.value.length >  0){
        $filter_searches_clear.addClass('is-active')
      }else{
        $filter_searches_clear.removeClass('is-active')
      }
    }
  })

  // when click on 'x' in search
  // reload page withouth the search param
  $filter_searches_clear.on('click', function(){
    toggle_loading_image()
    $filter_searches.find('input').val('')
    $filter_searches_clear.removeClass('is-active')
    reload_page_with_new_params({search: null})
  })


  ////////////////////////////////////////////
  // FUNCTIONS
  ////////////////////////////////////////////
  // show/hide filters on mobile
  $filter_button.on('click', function(){
    $filter_toggle.toggleClass('is-hidden-mobile')
  })

  // set date to null
  function reset_date(date_obj){
    date_obj.datepicker('setDate', null)
  }

  // when set a date to null,
  // it is still selected in the calendar,
  // so also remove the highlight class
  function reset_calendar_selections(date_obj){
    date_obj.find(".ui-datepicker-current-day a").removeClass("ui-state-highlight ui-state-active")
  }

  var toggle_loading_image = function(){
    $('.loading').toggleClass('is-active')
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

    if (window.location.toLocaleString() === (base_url + new_search)){
      // nothing changed so turn off loader
      toggle_loading_image()
    }else{
      // load the page with the updated filters
      window.location = base_url + new_search
    }
  }

  // set the month and year selects in the datepicker if
  // - datepicker value is today's date
  // - or forceSetting = true
  function set_datepicker_select_values(date_obj, month, year, forceSetting){
    if (date_obj.datepicker('getDate') === null || forceSetting === true){
      $(date_obj).find('.ui-datepicker-year').val(year)
      $(date_obj).find('.ui-datepicker-year').trigger('change')
      $(date_obj).find('.ui-datepicker-month').val(month)
      $(date_obj).find('.ui-datepicker-month').trigger('change')
    }
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
