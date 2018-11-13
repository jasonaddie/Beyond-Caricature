class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  # keep track of history (changes)
  has_paper_trail

  # define user roles
  enum role: [:uploader, :editor, :admin, :superadmin]

  #################
  ## VALIDATION ##
  #################
  validates :email, :presence => true
  validates :encrypted_password, :presence => true
  validates :role, :presence => true


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # list page
    list do
      field :email
      field :role
      field :created_at
      field :current_sign_in_at
      field :confirmation_sent_at
      field :confirmed_at
    end

    # show page
    show do
      field :email
      field :role
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
      field :email
      field :password
      field :password_confirmation
      field :role
    end
  end

end
