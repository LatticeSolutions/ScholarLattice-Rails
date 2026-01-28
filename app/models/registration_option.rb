class RegistrationOption < ApplicationRecord
  belongs_to :collection
  has_many :registrations, dependent: :destroy
  has_many :payments, through: :registrations

  before_save :clean_allowed_domains

  default_scope { order(name: :asc) }

  def closed?
    return false if closes_on.blank?
    closes_on <= Time.now
  end

  def open?
    return false if closed?
    return true if opens_on.blank?
    opens_on <= Time.now
  end

  def remaining_stock
    stock - registrations.count
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

  def availability
    if closed?
      return "Closed on #{closes_on.in_time_zone(collection.inherited_time_zone).strftime("%Y-%m-%d %-I:%M%p %Z")}"
    end
    if not open?
      return "Opens on #{opens_on.in_time_zone(collection.inherited_time_zone).strftime("%Y-%m-%d %-I:%M%p %Z")}"
    end
    if stock.present?
      return "#{remaining_stock} / #{stock} available"
    end
    nil
  end

  def name_with_cost_and_availability
    return name_with_cost if availability.blank?
    "#{name_with_cost} (#{availability})"
  end

  def allowed_domains_array
    return nil if allowed_domains.blank?
    allowed_domains.split(",").map(&:strip)
  end

  private

  def clean_allowed_domains
    if allowed_domains.present?
      domains = allowed_domains.split(",")
      domains.map! do |d|
        d.strip!
        d.downcase!
        # match regex for domains
        if d.match(/^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/)
          d
        else
          nil
        end
      end
      puts "foobarbaz"
      puts domains
      domains.compact!
      if domains.any?
        self.allowed_domains = domains.join(", ")
      else
        self.allowed_domains = nil
      end
    end
  end
end
