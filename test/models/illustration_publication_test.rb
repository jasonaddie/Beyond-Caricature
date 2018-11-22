# == Schema Information
#
# Table name: illustration_publications
#
#  id                :integer          not null, primary key
#  illustration_id   :integer
#  publication_id    :integer
#  page_number_start :integer
#  page_number_end   :integer
#  is_public         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class IllustrationPublicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
