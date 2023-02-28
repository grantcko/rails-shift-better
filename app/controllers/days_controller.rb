class DaysController < ApplicationController
  def index
    @days = policy_scope(Day)
  end

  def show
    @day = Day.find(params[:id])
    authorize @day
  end

  def create
    @day = Day.new(day_params)
    authorize @day
    if @day.save
      redirect_to days_path
    else
      render "days/index", status: :unprocessable_entity
    end
  end
end

private

def day_params
  params.require(:day).permit(:date, :approved)
end
