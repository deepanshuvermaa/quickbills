const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const path = require('path');
require('dotenv').config();

const { pool, createTables } = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '..')));

// Initialize database
createTables();

// Helper function to generate JWT
const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET || 'your-secret-key',
    { expiresIn: '7d' }
  );
};

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'QuickBills Auth API is running!' });
});

// Register endpoint
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password, accessDays = 30 } = req.body;

    // Validate input
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Check if user exists
    const userExists = await pool.query(
      'SELECT * FROM users WHERE email = $1 OR username = $2',
      [email, username]
    );

    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Calculate access_until date
    const accessUntil = new Date();
    accessUntil.setDate(accessUntil.getDate() + accessDays);

    // Create user
    const newUser = await pool.query(
      `INSERT INTO users (username, email, password, access_until) 
       VALUES ($1, $2, $3, $4) 
       RETURNING id, username, email, access_until, is_active`,
      [username, email, hashedPassword, accessUntil]
    );

    const user = newUser.rows[0];
    const token = generateToken(user);

    res.status(201).json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        accessUntil: user.access_until,
        isActive: user.is_active
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const userResult = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = userResult.rows[0];

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if user is active
    if (!user.is_active) {
      return res.status(403).json({ error: 'Account is deactivated' });
    }

    // Check if access has expired
    if (user.access_until && new Date(user.access_until) < new Date()) {
      return res.status(403).json({ error: 'Access has expired' });
    }

    const token = generateToken(user);

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        accessUntil: user.access_until,
        isActive: user.is_active
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Verify token endpoint
app.get('/api/auth/verify', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    
    // Get fresh user data
    const userResult = await pool.query(
      'SELECT id, username, email, access_until, is_active FROM users WHERE id = $1',
      [decoded.id]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];

    // Check if user is active
    if (!user.is_active) {
      return res.status(403).json({ error: 'Account is deactivated' });
    }

    // Check if access has expired
    if (user.access_until && new Date(user.access_until) < new Date()) {
      return res.status(403).json({ error: 'Access has expired' });
    }

    res.json({ valid: true, user });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// Admin endpoint to update user access duration
app.put('/api/admin/users/:userId/access', async (req, res) => {
  try {
    const { userId } = req.params;
    const { accessDays, isActive } = req.body;
    const adminToken = req.headers.authorization?.split(' ')[1];

    // Simple admin check - you should implement proper admin authentication
    if (adminToken !== process.env.ADMIN_TOKEN) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    let updateQuery = 'UPDATE users SET updated_at = CURRENT_TIMESTAMP';
    const values = [];
    let paramCount = 1;

    if (accessDays !== undefined) {
      const accessUntil = new Date();
      accessUntil.setDate(accessUntil.getDate() + accessDays);
      updateQuery += `, access_until = $${paramCount}`;
      values.push(accessUntil);
      paramCount++;
    }

    if (isActive !== undefined) {
      updateQuery += `, is_active = $${paramCount}`;
      values.push(isActive);
      paramCount++;
    }

    updateQuery += ` WHERE id = $${paramCount} RETURNING *`;
    values.push(userId);

    const result = await pool.query(updateQuery, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Update access error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all users (admin endpoint)
app.get('/api/admin/users', async (req, res) => {
  try {
    const adminToken = req.headers.authorization?.split(' ')[1];

    if (adminToken !== process.env.ADMIN_TOKEN) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const result = await pool.query(
      'SELECT id, username, email, access_until, is_active, created_at FROM users ORDER BY created_at DESC'
    );

    res.json({ users: result.rows });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});