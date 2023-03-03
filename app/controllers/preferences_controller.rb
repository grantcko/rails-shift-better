class PreferencesController < ApplicationController
  # @preference = Preference.new
  def index
    @preferences = []
    @day = Day.find(day_params)
    policy_scope(Preference).each do |preference|
      @preferences << preference if preference.day == @day
    end
  end

  def new
    @preference = Preference.new
    authorize @preference
    @types = []
    Preference.categories.each { |category| @types << category[0] }
    @day = Day.find(params[:day_id])
  end

  def create
    @day = Day.find(params[:day_id])
    @preference = Preference.new(preference_params)
    @preference.user = current_user
    @preference.day = @day
    authorize @preference
    if @preference.save
      redirect_to days_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:preference).permit(:category, :note, unavailable_shift_ids: [])
  end

  def day_params
    params.require(:format)
  end
end
