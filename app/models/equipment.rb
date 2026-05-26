class Equipment < ApplicationRecord
  belongs_to :category
  has_many :maintenance_records, dependent: :destroy

  STATUSES = %w[available in_use maintenance].freeze
  SERIAL_FORMAT = /\A[A-Z]{3}-\d{3}\z/

  validates :name, presence: true
  validates :serial_number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :category, presence: true
  validate :name_must_be_real
  validate :serial_number_format

  private

  def name_must_be_real
    return if name.blank?

    unless name.length >= 3 && name.match?(/[A-Za-z]/)
      errors.add(:name, "must be at least 3 characters and contain at least one letter")
    end
  end

  def serial_number_format
    return if serial_number.blank?
    return if serial_number.match?(SERIAL_FORMAT)

    errors.add(:serial_number, "must match format XXX-NNN (e.g. LAP-001)")
  end
end