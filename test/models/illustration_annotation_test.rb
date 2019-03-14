# == Schema Information
#
# Table name: illustration_annotations
#
#  id              :bigint(8)        not null, primary key
#  illustration_id :bigint(8)
#  sort            :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  x               :decimal(5, 4)
#  y               :decimal(5, 4)
#

require 'test_helper'

class IllustrationAnnotationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
