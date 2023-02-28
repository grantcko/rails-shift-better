class AssignmentsController < ApplicationController
  def update
    @assignment = Assignment.find(params[:assignment_id])
    @assignment.user = current_user
    authorize @assignment
  end
end
