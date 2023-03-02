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
  end

  def create
    preference_params
    @preference.user = current_user
    authorize @preference
  end
end

private

def preference_pararms
  params.require(:preference).permit(:date, :approved)
end

def day_params
  params.require(:format)
end
