# == Schema Information
#
# Table name: illustration_tags
#
#  id              :integer          not null, primary key
#  illustration_id :integer
#  tag_id          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class IllustrationTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
