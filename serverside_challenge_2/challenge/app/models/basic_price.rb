# frozen_string_literal: true

class BasicPrice < ApplicationRecord
  belongs_to :plan

  AMPERAGE_LIST = [ 10, 15, 20, 30, 40, 50, 60 ].freeze
  ERR_MESS_INVALID_AMPERAGE = "#{AMPERAGE_LIST.join('/')}のいずれかを指定してください。".freeze

  validates :amperage, presence: true, inclusion: { in: AMPERAGE_LIST }
  validates :price, numericality: { only_numeric: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 99999.99 }
  validates :plan, presence: true, uniqueness: { scope: :amperage }

  class << self
    def calc_prices(plans_hash, amperage)
      exists_ids = {}
      rows = BasicPrice.where(amperage: amperage).where(plan_id: plans_hash.keys)
      rows.each do |row|
        exists_ids[row.plan_id] = true
        plans_hash[row.plan_id][:price] += row.price
      end
      plans_hash.keys.each do |key|
        plans_hash.delete(key) if exists_ids[key].nil?
      end
      plans_hash
    end

    def check_amperage?(amperage)
      res = { is_error: !AMPERAGE_LIST.include?(amperage) }
      res[:error_object] = { field: "amperage", message: ERR_MESS_INVALID_AMPERAGE } if res[:is_error]
      res
    end
  end
end
