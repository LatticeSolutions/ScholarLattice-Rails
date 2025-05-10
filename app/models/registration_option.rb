class RegistrationOption < ApplicationRecord
  belongs_to :collection
  has_many :registrations, dependent: :destroy
  has_many :payments, through: :registrations

  def closed?
    return false if closes_on.blank?
    closes_on <= Time.now
  end

  def open?
    return false if closed?
    return true if opens_on.blank?
    opens_on <= Time.now
  end

  def in_stock?
    return true if stock.blank?
    registrations.count < stock
  end

  def available?
    in_stock? && opens_on <= Time.current && closes_on >= Time.current
  end

  def cents_formatted
    (cost.abs % 100).to_s.rjust(2, "0")
  end

  def cost_formated
    return "Free" if cost.blank? || cost == 0
    dollars = "#{cost.abs / 100}.#{cents_formatted}"
    return "$#{dollars}" if cost > 0
    "-$#{dollars}"
  end

  def name_with_cost
    return name if cost.blank?
    "#{name} (#{cost_formated})"
  end
end
