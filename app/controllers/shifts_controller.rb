class ShiftsController < ApplicationController
  def show
    @shift = Shift.find(params[:id])
  end
end
