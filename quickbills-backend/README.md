# QuickBills Authentication Backend

A PostgreSQL-based authentication backend for the QuickBills app with user access duration control.

## Features

- User registration with username, email, and password
- JWT-based authentication
- User access duration control (expiration dates)
- Admin endpoints to manage user access
- PostgreSQL database for data persistence

## API Endpoints

### Public Endpoints

#### Register User
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepassword123",
  "accessDays": 30  // Optional, defaults to 30 days
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword123"
}
```

#### Verify Token
```
GET /api/auth/verify
Authorization: Bearer <token>
```

### Admin Endpoints

#### Update User Access
```
PUT /api/admin/users/:userId/access
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "accessDays": 60,    // Extend access by 60 days from today
  "isActive": true     // Enable/disable account
}
```

#### Get All Users
```
GET /api/admin/users
Authorization: Bearer <admin-token>
```

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret key for JWT tokens
- `ADMIN_TOKEN` - Admin authentication token
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port (defaults to 3000)

## Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up PostgreSQL database and update `.env` file

3. Run in development mode:
   ```bash
   npm run dev
   ```

## Deployment on Railway

1. Push to GitHub
2. Create new Railway project
3. Connect GitHub repository
4. Add PostgreSQL database
5. Set environment variables
6. Deploy!

## Security Notes

- Always use strong JWT_SECRET and ADMIN_TOKEN in production
- PostgreSQL connection uses SSL in production
- Passwords are hashed using bcrypt
- Access duration is checked on each login and token verification