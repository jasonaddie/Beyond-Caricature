# == Schema Information
#
# Table name: slideshows
#
#  id             :bigint(8)        not null, primary key
#  sort           :integer          default(0)
#  image_uid      :string
#  imageable_type :string
#  imageable_id   :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class SlideshowTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
