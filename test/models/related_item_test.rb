# == Schema Information
#
# Table name: related_items
#
#  id                 :bigint(8)        not null, primary key
#  related_item_type  :integer
#  news_itemable_id   :integer
#  news_itemable_type :string
#  publication_id     :bigint(8)
#  illustration_id    :bigint(8)
#  illustrator_id     :bigint(8)
#  issue_id           :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class RelatedItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
