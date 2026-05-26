# Lab Equipment API — Week 4

A Rails 8 JSON API for tracking lab equipment by category, status, and maintenance history. Built for the Advanced Programming Week 4 project.

## Tech stack

- Ruby 3.3.8
- Rails 8.1 (API mode)
- SQLite3

## Features

- CRUD for **categories**, **equipment**, and **maintenance records**
- Filter equipment by `?status=` and maintenance records by `?equipment_id=`
- Model and database validations to keep data trustworthy
- Category delete protection when equipment still exists
- Cascade delete of maintenance records when equipment is removed

## Setup

### Prerequisites

- Ruby 3.3+
- Bundler
- On Linux, if native gems fail to build:

```bash
sudo apt install build-essential libsqlite3-dev pkg-config
```

### Install and run

```bash
cd lab_equipment_api

bundle config set --local path 'vendor/bundle'
bundle install

bin/rails db:migrate
bin/rails db:seed

bin/rails server
```

API base URL: **http://localhost:3000**

### Reset database

```bash
bin/rails db:reset
```

## Data model

### Category

| Column | Type   | Rules                                      |
|--------|--------|--------------------------------------------|
| name   | string | Required, unique, minimum 3 characters     |

- `has_many :equipment` (delete blocked if equipment exists)

### Equipment

| Column         | Type      | Rules                                                                 |
|----------------|-----------|-----------------------------------------------------------------------|
| name           | string    | Required, min 3 chars, at least one letter                            |
| serial_number  | string    | Required, unique, format `XXX-NNN` (e.g. `LAP-001`)                   |
| status         | string    | Required: `available`, `in_use`, or `maintenance` (default: available) |
| category_id    | reference | Required, foreign key to categories                                   |

- `belongs_to :category`
- `has_many :maintenance_records`, `dependent: :destroy`

### MaintenanceRecord

| Column        | Type      | Rules                                |
|---------------|-----------|--------------------------------------|
| description   | text      | Required                             |
| performed_at  | datetime  | Required, cannot be in the future    |
| equipment_id  | reference | Required, foreign key to equipment   |

- `belongs_to :equipment`

### Database constraints (`db/schema.rb`)

- Unique index on `categories.name`
- Unique index on `equipment.serial_number`
- Foreign key `equipment.category_id` → `categories`
- Default `equipment.status` = `"available"`
- Foreign key `maintenance_records.equipment_id` → `equipment`
- Composite index on `maintenance_records [equipment_id, performed_at]`

## Seed data

After `bin/rails db:seed`:

| Resource            | Count |
|---------------------|-------|
| Categories          | 4     |
| Equipment           | 8     |
| Maintenance records | 5     |

Categories: Computing, Optics, Networking, Electronics.

Some equipment has maintenance history; some has none.

## API endpoints

| Method | Path                      | Description                                              |
|--------|---------------------------|----------------------------------------------------------|
| GET    | `/categories`             | List all (ordered by name)                               |
| GET    | `/categories/:id`         | Show one (includes `equipment_count`)                    |
| POST   | `/categories`             | Create                                                   |
| PATCH  | `/categories/:id`         | Update                                                   |
| DELETE | `/categories/:id`       | Delete (409 if equipment still linked)                   |
| GET    | `/equipment`              | List all (ordered by name); `?status=` filter            |
| GET    | `/equipment/:id`          | Show one (category + maintenance records, newest first)  |
| POST   | `/equipment`              | Create                                                   |
| PATCH  | `/equipment/:id`        | Update                                                   |
| DELETE | `/equipment/:id`        | Delete (cascades maintenance records)                    |
| GET    | `/maintenance_records`    | List all (newest `performed_at` first); `?equipment_id=` |
| GET    | `/maintenance_records/:id`| Show one (includes equipment name)                       |
| POST   | `/maintenance_records`    | Create                                                   |
| PATCH  | `/maintenance_records/:id`| Update                                                   |
| DELETE | `/maintenance_records/:id`| Delete                                                   |

List routes:

```bash
bin/rails routes
```

### Request bodies (JSON)

```json
{ "category": { "name": "Computing" } }
```

```json
{
  "equipment": {
    "name": "Dell Laptop",
    "serial_number": "LAP-001",
    "status": "available",
    "category_id": 1
  }
}
```

```json
{
  "maintenance_record": {
    "description": "Replaced keyboard",
    "performed_at": "2025-01-15T10:00:00",
    "equipment_id": 1
  }
}
```

## HTTP status codes

| Situation                         | Code |
|-----------------------------------|------|
| Created                           | 201  |
| Read or updated                   | 200  |
| Deleted (empty body)              | 204  |
| Record not found                  | 404  |
| Validation failed                 | 422  |
| Cannot delete category with items | 409  |

### Error formats

Validation (422):

```json
{ "errors": ["Name can't be blank", "Serial number has already been taken"] }
```

Not found (404):

```json
{ "error": "Category not found" }
```

Conflict (409):

```json
{ "error": "Cannot delete category. 4 equipment items still belong to it." }
```

## Business rules

1. **Serial number format** — Must match `XXX-NNN` (three uppercase letters, dash, three digits).  
   Valid: `LAP-001`, `MIC-042`. Invalid: `lap-001`, `LAP-1`, `LP-001`.

2. **Maintenance date** — `performed_at` must be today or earlier (not in the future).

3. **Category name** — At least 3 characters. Rejects `""`, `"A"`, `"AB"`.

4. **Equipment name** — At least 3 characters and must contain at least one letter. Rejects `""`, `"AB"`, `"123"`, `"!!!"`.

## Example requests

```bash
# List equipment in maintenance
curl "http://localhost:3000/equipment?status=maintenance"

# Maintenance history for equipment id 3
curl "http://localhost:3000/maintenance_records?equipment_id=3"

# Create a category
curl -X POST http://localhost:3000/categories \
  -H "Content-Type: application/json" \
  -d '{"category":{"name":"Robotics"}}'
```

## Testing documentation

Full curl commands and responses for all endpoints and edge cases are in **`curl_tests.txt`** (grouped by task).

### Edge cases (Task 7) — expected status

| # | Scenario                                      | Expected |
|---|-----------------------------------------------|----------|
| 1 | Create equipment with `category_id: 999`      | 422      |
| 2 | Create equipment with duplicate serial number | 422      |
| 3 | Create equipment with status `broken`         | 422      |
| 4 | Create category with duplicate name           | 422      |
| 5 | Create maintenance with `equipment_id: 999`   | 422      |
| 6 | DELETE category that has equipment            | 409      |
| 7 | GET `/categories/999`                         | 404      |
| 8 | GET `/equipment/999`                          | 404      |
| 9 | PATCH `/categories/999`                         | 404      |
| 10| POST maintenance with future `performed_at`     | 422      |

## Project structure

```
app/models/          Category, Equipment, MaintenanceRecord
app/controllers/     Categories, Equipment, MaintenanceRecords
db/migrate/          Schema migrations with indexes and foreign keys
db/schema.rb         Current database structure
db/seeds.rb          Sample data (4 / 8 / 5 records)
curl_tests.txt       API test commands and responses
```

## Repository

<!-- Replace with your GitHub URL before submission -->
GitHub: `https://github.com/YOUR_USERNAME/lab-equipment-api`
