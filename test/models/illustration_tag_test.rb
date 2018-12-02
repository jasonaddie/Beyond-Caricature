# == Schema Information
#
# Table name: illustration_tags
#
#  id              :bigint(8)        not null, primary key
#  illustration_id :bigint(8)
#  tag_id          :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class IllustrationTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
