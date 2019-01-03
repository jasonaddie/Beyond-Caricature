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

class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  include Ckeditor::Backend::Dragonfly

  dragonfly_accessor :data, app: :ckeditor
  validates :data, presence: true
end
