# == Schema Information
#
# Table name: illustration_issues
#
#  id                :integer          not null, primary key
#  illustration_id   :integer
#  issue_id          :integer
#  page_number_start :integer
#  page_number_end   :integer
#  is_public         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class IllustrationIssue < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustration
  belongs_to :issue

  #################
  ## VALIDATION ##
  #################
end
