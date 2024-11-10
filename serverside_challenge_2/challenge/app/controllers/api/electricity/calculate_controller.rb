class Api::Electricity::CalculateController < ApplicationController
  def create
    @prices = price_calculate

    if @prices[:errors].present?
      render json: @prices[:errors], status: :bad_request
    else
      render "electricity/calculate/create", status: :ok
    end
  end

  private

  def create_params
    params.permit(:amperage, :electricity_usage_kwh)
  end

  def price_calculate
    Plan.calc_prices(create_params[:amperage], create_params[:electricity_usage_kwh])
  end
end
