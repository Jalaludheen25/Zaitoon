# Registration System

## API Endpoints

### Base URL
```
https://cenloginbackend.d4dx.co
```

### Endpoints

1. **Get Districts**
   - URL: `GET /api/districts`
   - Response: Array of district objects

2. **Get Areas by District**
   - URL: `GET /api/areas/district/{districtId}`
   - Response: Array of area objects

3. **Get Units by Area**
   - URL: `GET /api/halqas/area/{areaId}`
   - Response: Array of unit objects

4. **Registration CRUD**
   - GET: `GET /api/registrations`
   - POST: `POST /api/registrations`
   - DELETE: `DELETE /api/registrations/{id}`

## POST Request Body Format

```json
{
  "student_name": "John Doe",
  "class": "5th",
  "school_name": "ABC School",
  "gender": "Boy",
  "district_id": 1,
  "district_name": "Kozhikode",
  "area_id": 5,
  "area_name": "Calicut",
  "unit_id": 12,
  "unit_name": "Unit A"
}
```

## Features

- **Popup Form**: Registration form opens as a popup dialog
- **Cascading Dropdowns**: District → Area → Unit selection
- **Form Validation**: All fields are validated before submission
- **API Integration**: No local database, all data from APIs
- **Error Handling**: Proper error messages for API failures
- **Loading States**: Loading indicators for API calls

## Usage

1. Click the registration button (person_add icon) in the home screen header
2. Fill in student information (name, class, school, gender)
3. Select location information (district, area, unit) in order
4. Submit the form

The form will validate all fields and show appropriate error messages if validation fails or API calls fail.