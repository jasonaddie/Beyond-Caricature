# == Schema Information
#
# Table name: person_roles
#
#  id                   :bigint(8)        not null, primary key
#  person_id            :bigint(8)
#  person_roleable_type :string
#  person_roleable_id   :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  role                 :integer
#

require 'test_helper'

class PersonRoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
