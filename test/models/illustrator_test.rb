# == Schema Information
#
# Table name: illustrators
#
#  id         :integer          not null, primary key
#  date_birth :date
#  date_death :date
#  is_public  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class IllustratorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
