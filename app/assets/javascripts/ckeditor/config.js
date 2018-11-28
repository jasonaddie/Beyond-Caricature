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
};
