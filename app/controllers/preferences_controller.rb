class PreferencesController < ApplicationController
  # @preference = Preference.new
  def index
    @preferences = policy_scope(Preference)
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
