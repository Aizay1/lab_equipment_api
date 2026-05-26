class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
    private
  
    def render_errors(record, status: :unprocessable_entity)
      render json: { errors: record.errors.full_messages }, status: status
    end
  
    def record_not_found
      resource = controller_name.singularize.humanize
      render json: { error: "#{resource} not found" }, status: :not_found
    end
  end