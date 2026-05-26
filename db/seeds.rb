MaintenanceRecord.destroy_all
Equipment.destroy_all
Category.destroy_all

computing   = Category.create!(name: "Computing")
optics      = Category.create!(name: "Optics")
networking  = Category.create!(name: "Networking")
electronics = Category.create!(name: "Electronics")

Equipment.create!(name: "Dell Laptop",       serial_number: "LAP-001", status: "available",    category: computing)
Equipment.create!(name: "MacBook Pro",      serial_number: "LAP-002", status: "in_use",       category: computing)
Equipment.create!(name: "Digital Microscope", serial_number: "MIC-001", status: "available",  category: optics)
Equipment.create!(name: "Optical Bench",    serial_number: "OPT-001", status: "maintenance", category: optics)
Equipment.create!(name: "Cisco Router",     serial_number: "NET-001", status: "available",   category: networking)
Equipment.create!(name: "WiFi Access Point", serial_number: "NET-002", status: "in_use",     category: networking)
Equipment.create!(name: "Arduino Starter Kit", serial_number: "ARD-001", status: "available", category: electronics)
Equipment.create!(name: "Oscilloscope",     serial_number: "OSC-001", status: "maintenance", category: electronics)

eq1 = Equipment.find_by!(serial_number: "LAP-001")
eq2 = Equipment.find_by!(serial_number: "MIC-001")
eq3 = Equipment.find_by!(serial_number: "NET-001")
eq4 = Equipment.find_by!(serial_number: "OPT-001")
eq5 = Equipment.find_by!(serial_number: "OSC-001")

MaintenanceRecord.create!(
  equipment: eq1,
  description: "Replaced keyboard",
  performed_at: 2.months.ago
)
MaintenanceRecord.create!(
  equipment: eq2,
  description: "Cleaned lenses",
  performed_at: 1.month.ago
)
MaintenanceRecord.create!(
  equipment: eq3,
  description: "Firmware update",
  performed_at: 3.weeks.ago
)
MaintenanceRecord.create!(
  equipment: eq4,
  description: "Calibrated alignment",
  performed_at: 1.week.ago
)
MaintenanceRecord.create!(
  equipment: eq5,
  description: "Replaced fuse",
  performed_at: 2.days.ago
)

puts "Categories: #{Category.count}"
puts "Equipment: #{Equipment.count}"
puts "Maintenance records: #{MaintenanceRecord.count}"