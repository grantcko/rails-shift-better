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
    @shifts = Shift.where(day_id: params[:id])
    @day_shift_errors = {}
    authorize @day
    authorize @shifts
    User.all.each { |user| user.shift_errors = [] }
    User.all.each do |user| # each user
      @shifts.each do |shift| # each shift on that day
        user.can_be_assigned?(shift) # loading up error messages per shift
        # loading up the error given for each shift
        @day_shift_errors[[user.id, user.shift_errors[0]]] = user.shift_errors[1]
      end
    end
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
      random_users.each do |user|
        next unless user.can_be_assigned?(shift)

        @assignment = Assignment.new(shift:, user:)
        raise if @assignment.valid? == false
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

  def random_users
    ordered_users = []
    User.all.each { |user| ordered_users << user }
    random_users = []
    User.all.each { (num = rand(0...User.all.count)) && (random_users << ordered_users[num]) }
    random_users
  end
end
