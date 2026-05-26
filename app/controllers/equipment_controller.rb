class EquipmentController < ApplicationController
    before_action :set_equipment, only: %i[show update destroy]
  
    def index
      scope = Equipment.includes(:category).order(:name)
      scope = scope.where(status: params[:status]) if params[:status].present?
  
      render json: scope.map { |e| equipment_index_json(e) }
    end
  
    def show
      render json: equipment_show_json(@equipment)
    end
  
    def create
      equipment = Equipment.new(equipment_params)
      if equipment.save
        render json: equipment_index_json(equipment), status: :created
      else
        render_errors(equipment)
      end
    end
  
    def update
      if @equipment.update(equipment_params)
        render json: equipment_index_json(@equipment)
      else
        render_errors(@equipment)
      end
    end
  
    def destroy
      @equipment.destroy!
      head :no_content
    end
  
    private
  
    def set_equipment
      @equipment = Equipment.find(params[:id])
    end
  
    def equipment_params
      params.require(:equipment).permit(:name, :serial_number, :status, :category_id)
    end
  
    def equipment_index_json(equipment)
      {
        id: equipment.id,
        name: equipment.name,
        serial_number: equipment.serial_number,
        status: equipment.status,
        category_id: equipment.category_id,
        category_name: equipment.category.name
      }
    end
  
    def equipment_show_json(equipment)
      records = equipment.maintenance_records.order(performed_at: :desc)
      equipment_index_json(equipment).merge(
        category: { id: equipment.category.id, name: equipment.category.name },
        maintenance_records: records.map { |r|
          {
            id: r.id,
            description: r.description,
            performed_at: r.performed_at,
            equipment_id: r.equipment_id
          }
        }
      )
    end
  end