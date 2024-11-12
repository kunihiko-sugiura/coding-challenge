# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :provider
  has_many :basic_prices, dependent: :destroy
  has_many :measured_rates, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :provider, presence: true, uniqueness: { scope: :name }

  class << self
    def calc_plans(amperage, electricity_usage_kwh)
      errors = check_parameters(amperage, electricity_usage_kwh)
      if errors.present?
        return { errors: {
          message: "リクエストパラメーターが正しくありません。",
          details: errors
        } }
      end
      plans_hash = initial_plans_hash
      calc_items = [
        { klass: Plan, value: nil },
        { klass: BasicPrice, value: amperage },
        { klass: MeasuredRate, value: electricity_usage_kwh }
      ]
      calc_items.each do |item|
        plans_hash = item[:klass].calc_prices(plans_hash, item[:value])
      end
      response = plans_hash.values.map do |item|
        item[:price] = item[:price].floor;
        item
      end.sort_by { |item| [ item[:provider].id, item[:plan].id ] }

      { plans: response }
    end

    def calc_prices(data, _)
      # 現状でPlanの計算は行わないため、そのまま返す
      data
    end

    private

    def initial_plans_hash
      plans = Plan.all.includes(:provider)
      plans.each_with_object({}) do |plan, hash|
        hash[plan.id] = { plan: plan, provider: plan.provider, price: 0 }
      end
    end

    def check_parameters(amperage, electricity_usage_kwh)
      errors = [
        BasicPrice.check_amperage?(amperage),
        MeasuredRate.validate_electricity_usage?(electricity_usage_kwh)
      ]
      errors.select { |error| error[:is_error] }
            .map { |error| error[:error_object] }
    end
  end
end
