# == Schema Information
#
# Table name: publications
#
#  id                      :bigint(8)        not null, primary key
#  publication_type        :integer          default("journal")
#  publication_language_id :bigint(8)
#  year_publication_start  :integer
#  year_publication_end    :integer
#  date_publication        :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
