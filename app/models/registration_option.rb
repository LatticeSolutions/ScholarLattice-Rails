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

  def name_with_cost
    return name if cost.blank?
    "#{name} (#{Money.from_cents(cost, :usd).format})"
  end
end
