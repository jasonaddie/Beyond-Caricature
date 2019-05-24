# == Schema Information
#
# Table name: illustrations
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  image_uid      :string
#  person_id      :bigint(8)
#  crop_alignment :string           default("center")
#

require 'test_helper'

class IllustrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
