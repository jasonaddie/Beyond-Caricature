# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :integer          default("uploader")
#  name                   :string
#  is_active              :boolean          default(TRUE)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  # define user roles
  enum role: [:uploader, :editor, :admin, :superadmin]

  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## VALIDATION ##
  #################
  validates :name, presence: true
  validates :email, presence: true
  validates :encrypted_password, presence: true
  validates :role, presence: true


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # control the order in the admin nav menu
    weight 400

    # list page
    list do
      field :name
      field :email
      field :role
      field :is_active
      field :current_sign_in_at
    end

    # show page
    show do
      field :name
      field :email
      field :role
      field :is_active
      field :created_at
      field :updated_at
      field :sign_in_count
      field :current_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_at
      field :last_sign_in_ip
      field :remember_created_at
      field :reset_password_sent_at
      field :confirmation_token
      field :confirmation_sent_at
      field :confirmed_at
    end

    # form
    edit do
      field :name
      field :email
      field :password
      field :password_confirmation
      field :role
      field :is_active
    end
  end

end
