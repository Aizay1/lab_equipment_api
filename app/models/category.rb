class Category < ApplicationRecord
    has_many :equipment, dependent: :restrict_with_error
  
    validates :name, presence: true, uniqueness: true
    validate :name_minimum_length
  
    private
  
    def name_minimum_length
      return if name.blank?
      return if name.length >= 3
  
      errors.add(:name, "must be at least 3 characters")
    end
  end