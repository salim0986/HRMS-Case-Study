# API Design Documentation

## Overview

The HRMS API is built using NestJS and follows RESTful conventions. All endpoints require authentication via Supabase JWT tokens passed in the `Authorization` header as `Bearer <token>`. The API enforces role-based access control and multi-tenant data isolation.

**Base URL**: `http://localhost:3000` (development) or your configured production URL

**Authentication**: All protected endpoints require:
```
Authorization: Bearer <supabase_jwt_token>
```

## API Architecture Principles

### 1. Modular Design

The API is organized into feature modules, each responsible for a specific domain:

- **Authentication** (`/auth`) - User authentication and session management
- **Organizations** (`/orgs`) - Organization setup and configuration
- **Employees** (`/employees`, `/hr/employees`) - Employee management
- **Departments** (`/departments`) - Department structure and management
- **Leaves** (`/leaves`) - Leave application and management
- **Attendance** (`/attendance`) - Time tracking and shift management
- **Payrolls** (`/payrolls`) - Payroll processing and viewing
- **Approvals** (`/approvals`) - Generic approval workflows
- **Onboarding** (`/onboarding`) - New hire onboarding
- **Offboarding** (`/offboarding`) - Employee exit processes
- **Careers** (`/careers`) - Public job postings and applications
- **Notifications** (`/notifications`) - In-app notifications

### 2. Request Guards

Three guards protect endpoints in sequence:

1. **SupabaseAuthGuard**: Validates JWT token and loads employee context
2. **RolesGuard**: Checks if user has required role for the endpoint
3. **RequireActiveEmployeeGuard**: Ensures employee status is 'active'

### 3. Response Patterns

**Success Responses**:
```json
{
  "id": "uuid",
  "...": "entity fields"
}
```

**List Responses**:
```json
{
  "data": [...],
  "total": 100,
  "page": 1,
  "pageSize": 10
}
```

**Error Responses**:
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request"
}
```

### 4. Multi-Tenancy

All authenticated endpoints automatically scope data to the user's organization. The `organizationId` is extracted from the authenticated employee and used to filter all queries.

## Core API Endpoints

### Authentication

#### POST /auth/signup
Create a new user account with initial organization setup.

**Access**: Public

**Request**:
```json
{
  "email": "admin@company.com",
  "password": "securePassword123",
  "organizationName": "Acme Corp",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response**: Returns Supabase auth session with user data.

#### POST /auth/login
Authenticate user and receive JWT token.

**Access**: Public

**Request**:
```json
{
  "email": "user@company.com",
  "password": "password123"
}
```

**Response**: 
```json
{
  "access_token": "jwt_token_here",
  "user": {...}
}
```

### Organizations

#### GET /orgs/my
Get current user's organization details.

**Access**: All authenticated users

**Response**:
```json
{
  "id": "org-uuid",
  "name": "Acme Corp",
  "domain": "acme.com",
  "address": "123 Main St"
}
```

#### PATCH /orgs/my
Update organization details.

**Access**: Admin only

### Employees

#### GET /hr/employees
List all employees in organization.

**Access**: HR Manager, Admin

**Query Parameters**:
- `page` (number, default: 1)
- `pageSize` (number, default: 10)
- `status` (active | inactive | on_leave)
- `departmentId` (uuid)
- `q` (search term)

**Response**:
```json
{
  "data": [
    {
      "id": "employee-uuid",
      "employeeCode": "EMP001",
      "firstName": "Jane",
      "lastName": "Smith",
      "email": "jane@company.com",
      "role": "employee",
      "status": "active",
      "department": {...},
      "jobTitle": {...},
      "dateOfJoining": "2024-01-15"
    }
  ],
  "total": 50,
  "page": 1,
  "pageSize": 10
}
```

#### GET /hr/employees/:id
Get detailed employee information.

**Access**: HR Manager, Admin, Manager (for team members), Employee (own record)

**Response**: Complete employee object with relations (department, job title, manager, salary structure).

#### POST /hr/employees
Create new employee.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "email": "newuser@company.com",
  "firstName": "John",
  "lastName": "Doe",
  "departmentId": "dept-uuid",
  "jobTitleId": "title-uuid",
  "managerId": "manager-uuid",
  "dateOfJoining": "2024-02-01",
  "employmentType": "full_time",
  "role": "employee"
}
```

#### PATCH /hr/employees/:id
Update employee information.

**Access**: HR Manager, Admin

#### DELETE /hr/employees/:id
Soft delete employee (sets status to inactive).

**Access**: Admin only

### Departments

#### GET /departments
List all departments in organization.

**Access**: All authenticated users

**Response**:
```json
[
  {
    "id": "dept-uuid",
    "name": "Engineering",
    "code": "ENG",
    "managerId": "manager-uuid",
    "manager": {...},
    "employeeCount": 25
  }
]
```

#### POST /departments
Create new department.

**Access**: Admin only

**Request**:
```json
{
  "name": "Marketing",
  "code": "MKT",
  "managerId": "manager-uuid"
}
```

#### GET /departments/:id/details
Get department with comprehensive KPIs.

**Access**: Admin, HR Manager, Department Manager

**Response**:
```json
{
  "department": {...},
  "metrics": {
    "headcount": 25,
    "totalPayroll": 500000,
    "avgSalary": 20000,
    "attritionRate": 5.2,
    "newHires": 3,
    "exitingEmployees": 1
  }
}
```

### Leaves

#### POST /leaves/apply
Apply for leave.

**Access**: All authenticated users

**Request**:
```json
{
  "leaveTypeId": "leave-type-uuid",
  "startDate": "2024-03-01",
  "endDate": "2024-03-05",
  "reason": "Personal vacation",
  "halfDay": false
}
```

**Response**: Returns created leave record(s). May return multiple records if leave spans calendar years.

#### GET /leaves/my-history
Get authenticated user's leave history.

**Access**: All authenticated users

**Query Parameters**:
- `year` (number)
- `status` (pending | approved | rejected | cancelled)

#### GET /leaves/balance
Get leave balance summary for authenticated user.

**Access**: All authenticated users

**Response**:
```json
[
  {
    "leaveType": "Casual Leave",
    "allocated": 12,
    "used": 5,
    "pending": 2,
    "available": 5
  },
  {
    "leaveType": "Sick Leave",
    "allocated": 10,
    "used": 2,
    "pending": 0,
    "available": 8
  }
]
```

#### GET /hr/leaves
List all leave requests (HR view).

**Access**: HR Manager, Admin

**Query Parameters**:
- `status` (pending | approved | rejected | cancelled)
- `employeeId` (uuid)
- `month` (YYYY-MM)
- `page`, `pageSize`

#### PATCH /hr/leaves/:id/approve
Approve leave request.

**Access**: HR Manager, Admin, Manager (for direct reports)

#### PATCH /hr/leaves/:id/reject
Reject leave request.

**Access**: HR Manager, Admin, Manager (for direct reports)

**Request**:
```json
{
  "reason": "Insufficient leave balance"
}
```

### Attendance

#### POST /attendance/clock-in
Record clock-in time.

**Access**: All authenticated users

**Request**:
```json
{
  "timestamp": "2024-03-01T09:00:00Z",
  "location": "Office"
}
```

#### POST /attendance/clock-out
Record clock-out time.

**Access**: All authenticated users

#### GET /attendance/my-records
Get attendance records for authenticated user.

**Access**: All authenticated users

**Query Parameters**:
- `startDate` (YYYY-MM-DD)
- `endDate` (YYYY-MM-DD)
- `month` (YYYY-MM)

#### GET /hr/attendance
List attendance records (HR view).

**Access**: HR Manager, Admin

**Query Parameters**:
- `employeeId` (uuid)
- `departmentId` (uuid)
- `date` (YYYY-MM-DD)
- `month` (YYYY-MM)

#### POST /hr/attendance/regularize
Create attendance regularization request.

**Access**: All authenticated users

**Request**:
```json
{
  "date": "2024-03-01",
  "clockIn": "09:00:00",
  "clockOut": "18:00:00",
  "reason": "Forgot to mark attendance"
}
```

### Payrolls

#### POST /payrolls
Create new payroll run.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "month": "2024-03",
  "title": "March 2024 Payroll"
}
```

#### GET /payrolls
List payroll runs.

**Access**: HR Manager, Admin

**Query Parameters**:
- `status` (draft | posted | processing | paid)
- `year` (number)
- `page`, `pageSize`

#### GET /payrolls/:id
Get payroll details with all employee items.

**Access**: HR Manager, Admin

#### PATCH /payrolls/:id
Update payroll (only in draft status).

**Access**: HR Manager, Admin

#### POST /payrolls/:id/post
Post payroll for review (transitions from draft to posted).

**Access**: HR Manager, Admin

#### POST /payrolls/:id/process
Process payroll for payment (transitions from posted to processing).

**Access**: Admin only

**Request**:
```json
{
  "paymentDate": "2024-03-31",
  "notes": "Standard monthly payroll"
}
```

#### POST /payrolls/:id/paid
Mark payroll as paid (final state).

**Access**: Admin only

#### GET /payrolls/employee/:employeeId
Get payroll history for specific employee.

**Access**: HR Manager, Admin, Employee (own records)

#### GET /payrolls/:id/payslip/:employeeId
Generate and download payslip PDF.

**Access**: HR Manager, Admin, Employee (own payslip)

### Approvals

#### GET /approvals
List approvals pending for current user.

**Access**: All authenticated users

**Query Parameters**:
- `status` (pending | approved | rejected)
- `type` (leave | attendance | custom)

**Response**:
```json
{
  "data": [
    {
      "id": "approval-uuid",
      "type": "leave",
      "requesterId": "employee-uuid",
      "requester": {...},
      "status": "pending",
      "relatedEntityId": "leave-uuid",
      "createdAt": "2024-03-01T10:00:00Z"
    }
  ],
  "total": 5
}
```

#### GET /approvals/my-requests
List approvals submitted by current user.

**Access**: All authenticated users

#### POST /approvals/:id/approve
Approve a request.

**Access**: User assigned as approver

**Request**:
```json
{
  "comments": "Approved"
}
```

#### POST /approvals/:id/reject
Reject a request.

**Access**: User assigned as approver

**Request**:
```json
{
  "reason": "Insufficient justification"
}
```

#### GET /approvals/summary
Get approval summary statistics.

**Access**: All authenticated users

**Response**:
```json
{
  "pendingCount": 5,
  "approvedToday": 8,
  "rejectedToday": 1,
  "byType": {
    "leave": 3,
    "attendance": 2
  }
}
```

### Onboarding

#### POST /onboarding
Create onboarding record for new hire.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "employeeId": "employee-uuid",
  "startDate": "2024-03-15",
  "mentor": "mentor-uuid",
  "notes": "Standard onboarding process"
}
```

#### GET /onboarding
List onboarding records.

**Access**: HR Manager, Admin

**Query Parameters**:
- `status` (pending | in_progress | completed | cancelled)
- `month` (YYYY-MM)
- `q` (search term)

#### GET /onboarding/:id
Get detailed onboarding record with tasks.

**Access**: HR Manager, Admin, assigned employee

#### POST /onboarding/:id/tasks
Add task to onboarding checklist.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "title": "Complete I-9 form",
  "description": "Fill out employment eligibility verification",
  "dueDate": "2024-03-20",
  "priority": "high"
}
```

#### PATCH /onboarding/:id/tasks/:taskId
Update task status.

**Access**: HR Manager, Admin, assigned employee

**Request**:
```json
{
  "status": "completed",
  "completedAt": "2024-03-18T14:30:00Z"
}
```

#### GET /onboarding/summary
Get onboarding summary statistics.

**Access**: HR Manager, Admin

**Response**:
```json
{
  "activeOnboardings": 5,
  "completedThisMonth": 3,
  "upcomingStarts": 2,
  "avgCompletionTime": 14
}
```

### Offboarding

#### POST /offboarding
Initiate offboarding process.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "employeeId": "employee-uuid",
  "lastWorkingDay": "2024-04-30",
  "reason": "resignation",
  "notes": "Two weeks notice provided"
}
```

#### GET /offboarding
List offboarding records.

**Access**: HR Manager, Admin

#### GET /offboarding/:id
Get detailed offboarding record with clearance items.

**Access**: HR Manager, Admin

#### POST /offboarding/:id/clearance
Add clearance item.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "department": "IT",
  "item": "Return laptop and access card",
  "assignedTo": "it-manager-uuid"
}
```

#### PATCH /offboarding/:id/clearance/:clearanceId
Update clearance status.

**Access**: HR Manager, Admin, assigned person

**Request**:
```json
{
  "status": "cleared",
  "notes": "All items returned"
}
```

### Careers (Public Endpoints)

#### GET /careers/jobs
List active job postings (public).

**Access**: Public

**Query Parameters**:
- `location` (string)
- `type` (full_time | part_time | contract)

**Response**:
```json
{
  "data": [
    {
      "id": "job-uuid",
      "title": "Senior Software Engineer",
      "department": "Engineering",
      "location": "Remote",
      "type": "full_time",
      "description": "...",
      "requirements": "...",
      "postedDate": "2024-03-01"
    }
  ]
}
```

#### GET /careers/jobs/:id
Get job posting details (public).

**Access**: Public

#### POST /careers/apply
Submit job application (public).

**Access**: Public

**Request** (multipart/form-data):
```
jobPostId: uuid
firstName: string
lastName: string
email: string
phone: string
resume: file
coverLetter: file (optional)
linkedIn: string (optional)
```

#### GET /careers/applications
List applications for job postings (HR view).

**Access**: HR Manager, Admin

#### PATCH /careers/applications/:id
Update application status.

**Access**: HR Manager, Admin

**Request**:
```json
{
  "status": "shortlisted",
  "notes": "Strong candidate, schedule interview"
}
```

### Notifications

#### GET /notifications
List notifications for current user.

**Access**: All authenticated users

**Query Parameters**:
- `unreadOnly` (boolean)
- `page`, `pageSize`

#### PATCH /notifications/:id/read
Mark notification as read.

**Access**: All authenticated users

#### POST /notifications/mark-all-read
Mark all notifications as read.

**Access**: All authenticated users

## Data Transfer Objects (DTOs)

All request bodies are validated using class-validator decorators. Common validation rules:

- **Email**: Must be valid email format
- **UUID**: Must be valid UUID v4
- **Dates**: Must be ISO 8601 format (YYYY-MM-DD)
- **Enums**: Must match predefined values
- **Required fields**: Cannot be null or undefined

Example DTO structure:
```typescript
class CreateEmployeeDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(2)
  firstName: string;

  @IsUUID()
  departmentId: string;

  @IsEnum(EmploymentType)
  employmentType: EmploymentType;

  @IsDateString()
  dateOfJoining: string;
}
```

## Error Handling

Standard HTTP status codes are used:

- **200 OK**: Successful GET request
- **201 Created**: Successful POST request
- **400 Bad Request**: Validation error or invalid input
- **401 Unauthorized**: Missing or invalid authentication token
- **403 Forbidden**: User lacks permission for the action
- **404 Not Found**: Resource does not exist
- **409 Conflict**: Resource conflict (e.g., duplicate email)
- **500 Internal Server Error**: Unexpected server error

Error response format:
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    "email must be a valid email address",
    "firstName should not be empty"
  ]
}
```

## Pagination

List endpoints support pagination with query parameters:

- `page`: Page number (1-based, default: 1)
- `pageSize`: Items per page (default: 10, max: 100)

Response includes pagination metadata:
```json
{
  "data": [...],
  "total": 156,
  "page": 2,
  "pageSize": 10,
  "totalPages": 16
}
```

## Filtering & Search

Many endpoints support filtering and search:

- **Status filters**: Filter by entity status (active, pending, etc.)
- **Date filters**: Filter by date ranges or specific months
- **Relationship filters**: Filter by related entity IDs (department, manager, etc.)
- **Text search**: Generic search with `q` parameter (searches across multiple fields)

## Rate Limiting

While not currently implemented in the provided code, production deployments should consider:

- Rate limiting by IP address
- Per-user request quotas
- Throttling for expensive operations (reports, bulk operations)

## API Documentation

The API uses Swagger/OpenAPI for interactive documentation. Access it at:

```
http://localhost:3000/api/docs
```

This provides:
- Interactive API explorer
- Request/response schemas
- Authentication testing
- Example values

## Integration Best Practices

When integrating with this API:

1. **Always handle authentication**: Store JWT tokens securely and refresh when expired
2. **Respect rate limits**: Implement backoff strategies for retries
3. **Validate inputs**: Client-side validation improves UX but server validates too
4. **Handle errors gracefully**: Parse error messages and display user-friendly feedback
5. **Use pagination**: Don't request all records at once for large datasets
6. **Cache responses**: Use ETags or timestamps to avoid unnecessary requests
7. **Organization context**: Remember all data is scoped to the user's organization

## Future API Enhancements

Planned improvements include:

- GraphQL endpoint for flexible querying
- Webhook subscriptions for real-time updates
- Bulk operation endpoints for batch processing
- Export APIs for data portability
- Advanced search with Elasticsearch
- API versioning for backward compatibility
