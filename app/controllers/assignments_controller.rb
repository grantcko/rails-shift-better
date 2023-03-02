class AssignmentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create destroy]
  def create
    @assignment = Assignment.new(assignment_params)
    authorize @assignment
    @assignment.save
    render json: @assignment
  end

  def update
    @assignment = Assignment.find(params[:assignment_id])
    @assignment.user = current_user
    authorize @assignment
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    authorize @assignment
    @assignment.destroy
  end

  private

  def assignment_params
    params.require(:assignment).permit(:user_id, :shift_id)
  end
end
