# == Schema Information
#
# Table name: illustrations
#
#  id             :integer          not null, primary key
#  illustrator_id :integer
#  is_public      :boolean          default(FALSE)
#  date_publish   :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class IllustrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
