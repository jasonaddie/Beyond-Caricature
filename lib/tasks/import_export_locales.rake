require 'yaml'
require 'csv'
require 'i18n'
require 'fileutils'
require 'import_export_locales'

namespace :translations do

  locale_file_path = ''
  export_file_prefix = "schmerling"
  here = File.expand_path(File.dirname(__FILE__))
  root = File.expand_path(File.join(here, "..", ".."))
  config_folder = File.join(root, "config")
  directory(import_folder = File.join(config_folder, "translations", "import"))
  directory(export_folder = File.join(config_folder, "translations", "export"))
  I18n.load_path << Dir[Rails.root.join('config', 'locales', '*.yml')]
  I18n.load_path.flatten!

  desc "Import CSVs from #{import_folder.sub(/^#{root}/,'')}"
  task :import => [import_folder] do
    ImportExportLocales::TranslationsImporter.import(export_file_prefix, import_folder)
  end

  desc "Export CSVs to #{export_folder.sub(/^#{root}/,'')}"
  task :export, [:locale_file_path] => [export_folder] do |t, args|
    locale_file_path = args[:locale_file_path].nil? ? locale_file_path : args[:locale_file_path]
    export_folder = args[:export_folder].nil? ? export_folder : args[:export_folder]
    ImportExportLocales::TranslationsExporter.export(export_file_prefix, locale_file_path, export_folder)
  end

end
