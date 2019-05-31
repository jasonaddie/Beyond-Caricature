# == Schema Information
#
# Table name: issues
#
#  id                :bigint(8)        not null, primary key
#  publication_id    :bigint(8)
#  issue_number      :string
#  date_publication  :date
#  is_public         :boolean          default(FALSE)
#  date_publish_old  :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_uid   :string
#  scanned_file_uid  :string
#  slug              :string
#  scanned_file_size :integer
#  crop_alignment    :string           default("center")
#  published_at      :datetime
#

require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
