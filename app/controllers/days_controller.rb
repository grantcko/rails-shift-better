class DaysController < ApplicationController
  def index
    @days = policy_scope(Day)
    @shifts = Shift.all
    @this_month = month_of_days(@days)
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
    # create 31 days
    # create 3 shifts per day
    # create 3 assignments per shift
    # iterate over users
    ## create empty list of off days (array of off days)
    ## assign day off based on preference (at least 3 days off)
    ## assign 6 days off randomly from the days where there are no user preferences (not shift preferences)
    ## assign day off has already worked 6 days in a row
    ## assign day off





    ## check if user has already worked for 9 days less than the total count of days that month

    # off_days = [date_chosen, date_chosen, date_chosen, date_auto_picked, date_auto_picked, date_auto_picked, date_auto_picked, date_auto_picked, date_auto_picked]
    # assignment_date = Day.all.sample while off_days.include?(assignment_date)
    # Assignment.new(date: assignment_date )
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
