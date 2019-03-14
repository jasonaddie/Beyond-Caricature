# == Schema Information
#
# Table name: people
#
#  id         :bigint(8)        not null, primary key
#  roles      :integer          default([]), not null, is an Array
#  date_birth :date
#  date_death :date
#  image_uid  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
