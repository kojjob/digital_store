class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_picture

  # Override the profile_picture accessor to ensure it returns the attachment
  # This prevents the NoMethodError when calling attached? on nil
  def profile_picture_attachment
    super
  end

  # Returns the user's full name by combining first_name and last_name
  def full_name
    [ first_name, last_name ].compact.join(" ")
  end
end
