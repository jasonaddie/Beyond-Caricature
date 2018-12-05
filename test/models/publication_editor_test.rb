# == Schema Information
#
# Table name: publication_editors
#
#  id             :bigint(8)        not null, primary key
#  publication_id :bigint(8)
#  year_start     :integer
#  year_end       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class PublicationEditorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
