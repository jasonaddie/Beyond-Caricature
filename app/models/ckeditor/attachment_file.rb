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

class Ckeditor::AttachmentFile < Ckeditor::Asset
  validates_property :ext, of: :data, in: attachment_file_types unless attachment_file_types.empty?

  def url_thumb
    Ckeditor::Utils.filethumb(filename)
  end
end
