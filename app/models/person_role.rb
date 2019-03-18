class PersonRole < ApplicationRecord

  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :person
  belongs_to :person_roleable, :polymorphic => true
end
