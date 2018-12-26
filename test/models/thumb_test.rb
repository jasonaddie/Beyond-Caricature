# == Schema Information
#
# Table name: thumbs
#
#  id         :bigint(8)        not null, primary key
#  uid        :string
#  job        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ThumbTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
