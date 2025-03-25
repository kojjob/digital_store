class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_picture

  # Virtual attribute for removing profile picture
  attr_accessor :remove_profile_picture

  # Safely check if profile picture is attached
  def has_profile_picture?
    profile_picture.attached? rescue false
  end

  # Override the profile_picture accessor to ensure it returns the attachment
  # This prevents the NoMethodError when calling attached? on nil
  def profile_picture_attachment
    super
  end

  # Returns the user's full name by combining first_name and last_name
  def full_name
    [ first_name, last_name ].compact.join(" ")
  end

  # Handle profile picture removal before saving
  before_save :check_profile_picture_removal

  private

  def check_profile_picture_removal
    if remove_profile_picture == "1" && profile_picture.attached?
      profile_picture.purge
    end
  end
end
