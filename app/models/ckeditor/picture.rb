# == Schema Information
#
# Table name: ckeditor_assets
#
#  id             :bigint(8)        not null, primary key
#  data_uid       :string           not null
#  data_name      :string           not null
#  data_mime_type :string
#  data_size      :integer
#  type           :string(30)
#  data_width     :integer
#  data_height    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Ckeditor::Picture < Ckeditor::Asset
  validates_property :format, of: :data, in: image_file_types unless image_file_types.empty?
  validates_property :image?, of: :data, as: true, message: :invalid

  def url_content
    data.thumb('800x800>').url
  end

  def url_thumb
    data.thumb('118x100#').url(url_thumb_options)
  end
end
