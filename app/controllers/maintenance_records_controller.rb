class MaintenanceRecordsController < ApplicationController
    before_action :set_maintenance_record, only: %i[show update destroy]
  
    def index
      scope = MaintenanceRecord.includes(:equipment).order(performed_at: :desc)
      scope = scope.where(equipment_id: params[:equipment_id]) if params[:equipment_id].present?
  
      render json: scope.map { |r| maintenance_record_json(r) }
    end
  
    def show
      render json: maintenance_record_json(@maintenance_record)
    end
  
    def create
      record = MaintenanceRecord.new(maintenance_record_params)
      if record.save
        render json: maintenance_record_json(record), status: :created
      else
        render_errors(record)
      end
    end
  
    def update
      if @maintenance_record.update(maintenance_record_params)
        render json: maintenance_record_json(@maintenance_record)
      else
        render_errors(@maintenance_record)
      end
    end
  
    def destroy
      @maintenance_record.destroy!
      head :no_content
    end
  
    private
  
    def set_maintenance_record
      @maintenance_record = MaintenanceRecord.find(params[:id])
    end
  
    def maintenance_record_params
      params.require(:maintenance_record).permit(:description, :performed_at, :equipment_id)
    end
  
    def maintenance_record_json(record)
      {
        id: record.id,
        description: record.description,
        performed_at: record.performed_at,
        equipment_id: record.equipment_id,
        equipment_name: record.equipment.name
      }
    end
  end