# == Schema Information
#
# Table name: publications
#
#  id                      :bigint(8)        not null, primary key
#  publication_type        :integer
#  publication_language_id :bigint(8)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  year                    :integer
#  cover_image_uid         :string
#  scanned_file_uid        :string
#

require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
