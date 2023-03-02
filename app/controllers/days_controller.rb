class DaysController < ApplicationController
  def index
    @days = policy_scope(Day)
    @shifts = Shift.all
    @this_month = month_of_days(@days)
    if params[:query].present?
      @users = User.search_by_name(params[:query])
    else
      @users = User.all
    end
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

  def create_month
    Assignment.destroy_all
    Shift.all.each do |shift|
      User.all.each do |user|
        @assignment = Assignment.new(shift:, user:) if user.can_be_assigned?(shift)
        authorize @assignment
        @assignment.save
      end
    end
  end

  private

  def day_params
    params.require(:day).permit(:date, :approved)
  end

  def month_of_days(days)
    months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"]
    months[days.first.date.month - 1]
  end
end
