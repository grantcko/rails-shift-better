class DaysController < ApplicationController
  def index
    @days = policy_scope(Day)
    @shifts = Shift.all
    @this_month = month_of_days(@days)
    @current_user = current_user
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
      ordered_users = []
      User.all.each { |user| ordered_users << user }
      random_users = []
      User.all.each do |user|
        num = rand(User.all.count) - 1
        random_users << ordered_users[num]
      end
      random_users.each do |user|
        next unless user.can_be_assigned?(shift)

        @assignment = Assignment.new(shift:, user:)
        authorize @assignment
        @assignment.save
      end
    end
    redirect_to days_path
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
