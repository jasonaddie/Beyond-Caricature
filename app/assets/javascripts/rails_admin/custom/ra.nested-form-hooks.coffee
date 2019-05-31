$ = jQuery

# need to override the nested form hook events
# located here: https://github.com/sferik/rails_admin/blob/master/app/assets/javascripts/rails_admin/ra.nested-form-hooks.coffee
# so turn them off and then re-create our updated event hooks
$(document).off 'nested:fieldAdded'
$(document).off 'nested:fieldRemoved'


$(document).on 'nested:fieldAdded', 'form', (content) ->
  field = content.field.addClass('tab-pane').attr('id', 'unique-id-' + (new Date().getTime()))
  new_tab = $('<li><a data-toggle="tab" href="#' + field.attr('id') + '">' + field.children('.object-infos').data('object-label') + '</a></li>')
  parent_group = field.closest('.control-group')
  controls = parent_group.children('.controls')
  one_to_one = controls.data('nestedone') != undefined
  nav = controls.children('.nav')
  tab_content = parent_group.children('.tab-content')
  tab_footer = parent_group.children('.tab-content-footer')
  toggler = controls.find('.toggler')
  nav.append(new_tab)
  $(window.document).trigger('rails_admin.dom_ready', [field, parent_group]) # fire dom_ready for new player in town
  new_tab.children('a').tab('show') # activate added tab
  nav.select(':hidden').show('slow') unless one_to_one # show nav if hidden
  tab_content.select(':hidden').show('slow') # show tabs content if hidden
  tab_footer.select(':hidden').show('slow') # show tabs footer if hidden
  # toggler 'on' if inactive
  toggler.addClass('active').removeClass('disabled').children('i').addClass('icon-chevron-down').removeClass('icon-chevron-right')

  # Convert the "add nested field" button to just showing the title of the new model
  controls.find('.add_nested_fields').removeClass('add_nested_fields').html(field.children('.object-infos').data('object-label')) if one_to_one

  # if the content has globalize tabs,
  # - update globalize data target temp-id-placeholder with real number
  # - need to replace in each tab and each tab-pane
  if content.field.find('.nav.globalize-tabs').length > 0
    placeholder = '[temp-id-placeholder]'
    temp_id = new Date().getTime().toString()
    content.field.find('.controls .nav li a').each (i, element) ->
      $(element).data('target', $(element).data('target').replace(placeholder, temp_id))
    content.field.find('.tab-content .tab-pane').each (i, element) ->
      # find the class
      cls = null
      element.classList.forEach (class_name) ->
        if cls == null && class_name.includes(placeholder)
          cls = class_name

      # update the class name
      if cls
        $(element).addClass(cls.replace(placeholder, temp_id)).removeClass(cls)


  if content.field.closest('.tab-content.annotations').length > 0
    # when annotation is added
    # - show image section
    # - if image is not in section, load it
    annotate_imgs = new annotate_image()
    annotate_imgs.show_image_section()

  if content.field.closest('.tab-content.sort-items').length > 0
    # when an item with sorting is added
    # update all of the sort values
    update_sortable_sort_values(content.field.closest('.tab-content.sort-items'))



$(document).on 'nested:fieldRemoved', 'form', (content) ->
  field = content.field
  nav = field.closest(".control-group").children('.controls').children('.nav')
  current_li = nav.children('li').has('a[href="#' + field.attr('id') + '"]')
  parent_group = field.closest(".control-group")
  controls = parent_group.children('.controls')
  one_to_one = controls.data('nestedone') != undefined
  toggler = controls.find('.toggler')


  if content.field.closest('.tab-content.annotations').length > 0
    # update the markers to reflect the change
    annotate_imgs = new annotate_image()
    annotate_imgs.remove_markers()
    annotate_imgs.add_markers()

  # try to activate another tab
  (if current_li.next().length then current_li.next() else current_li.prev()).children('a:first').tab('show')

  current_li.remove()

  if nav.children().length == 0 # removed last tab
    nav.select(':visible').hide('slow') # hide nav. No use anymore.
    # toggler 'off' if active
    toggler.removeClass('active').addClass('disabled').children('i').removeClass('icon-chevron-down').addClass('icon-chevron-right')

  if one_to_one
    # Converts the title button to an "add nested field" button
    add_button = toggler.next()
    add_button.addClass('add_nested_fields').html(add_button.data('add-label'))

  # Removing all required attributes from deleted child form to bypass browser validations.
  field.find('[required]').each ->
    $(this).removeAttr('required')

