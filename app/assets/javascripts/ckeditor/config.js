// To generate configuration: http://ckeditor.com/latest/samples/toolbarconfigurator/index.html#basic

CKEDITOR.editorConfig = function( config ) {
  config.toolbarGroups = [
    { name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
    { name: 'editing', groups: [ 'find', 'selection', 'spellchecker', 'editing' ] },
    { name: 'forms', groups: [ 'forms' ] },
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
    { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi', 'paragraph' ] },
    { name: 'links', groups: [ 'links' ] },
    { name: 'insert', groups: [ 'insert' ] },
    { name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
    { name: 'styles', groups: [ 'styles' ] },
    { name: 'colors', groups: [ 'colors' ] },
    { name: 'tools', groups: [ 'tools' ] },
    { name: 'others', groups: [ 'others' ] },
    { name: 'about', groups: [ 'about' ] }
  ];

  config.removeButtons = 'Source,Save,Templates,NewPage,Preview,Print,SelectAll,Form,HiddenField,Checkbox,Radio,TextField,Select,Textarea,Button,ImageButton,Strike,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Anchor,Flash,Smiley,SpecialChar,PageBreak,Styles,Format,Font,FontSize,TextColor,BGColor,ShowBlocks,About,Subscript,Superscript,Cut,Copy,Find,Replace,Scayt,HorizontalRule,Table';

  // register the urls for file uploads
  config.filebrowserBrowseUrl           = "/ckeditor/attachment_files"
  config.filebrowserFlashBrowseUrl      = "/ckeditor/attachment_files"
  config.filebrowserFlashUploadUrl      = "/ckeditor/attachment_files"
  config.filebrowserImageBrowseLinkUrl  = "/ckeditor/pictures"
  config.filebrowserImageBrowseUrl      = "/ckeditor/pictures"
  config.filebrowserImageUploadUrl      = "/ckeditor/pictures"
  config.filebrowserUploadUrl           = "/ckeditor/attachment_files"

  // csrf setup for file upload
  config.filebrowserParams = function() {
    var csrf_param, csrf_token, i, meta, metas, params;
    csrf_token = void 0;
    csrf_param = void 0;
    meta = void 0;
    metas = document.getElementsByTagName("meta");
    params = new Object();
    i = 0;
    while (i < metas.length) {
      meta = metas[i];
      switch (meta.name) {
        case "csrf-token":
          csrf_token = meta.content;
          break;
        case "csrf-param":
          csrf_param = meta.content;
          break;
        default:
          i++;
          continue;
      }
      i++;
    }
    if (csrf_param !== undefined && csrf_token !== undefined) {
      params[csrf_param] = csrf_token;
    }
    return params;
  };

};


CKEDITOR.on('dialogDefinition', function(ev) {

  try {

    var dialogName = ev.data.name;
    var dialogDefinition = ev.data.definition;

    if (dialogName == 'link') {

      var informationTab = dialogDefinition.getContents('target');

      var targetField = informationTab.get('linkTargetType');

      targetField['default'] = '_blank';

    }

  } catch (exception) {

    alert('Error ' + ev.message);

  }

});