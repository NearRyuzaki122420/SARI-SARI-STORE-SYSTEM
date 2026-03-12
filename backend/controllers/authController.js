const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
      if (err) return res.status(500).json({ message: 'Database error', error: err });

      if (results.length > 0) {
        return res.status(400).json({ message: 'Email already exists' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      db.query(
        'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
        [name, email, hashedPassword],
        (insertErr, result) => {
          if (insertErr) {
            return res.status(500).json({ message: 'Failed to register user', error: insertErr });
          }

          res.status(201).json({
            message: 'User registered successfully',
            userId: result.insertId
          });
        }
      );
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

exports.login = (req, res) => {
  const { email, password } = req.body;

  db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', error: err });

    if (results.length === 0) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const user = results[0];
    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email },
      'secretkey',
      { expiresIn: '1d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    });
  });
};

exports.forgotPassword = (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email is required' });
  }

  db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', error: err });

    if (results.length === 0) {
      return res.status(404).json({ message: 'Email not found' });
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 1000 * 60 * 30);

    db.query('DELETE FROM password_resets WHERE email = ?', [email], (deleteErr) => {
      if (deleteErr) {
        return res.status(500).json({ message: 'Failed to clear old reset tokens', error: deleteErr });
      }

      db.query(
        'INSERT INTO password_resets (email, token, expires_at) VALUES (?, ?, ?)',
        [email, resetToken, expiresAt],
        async (insertErr) => {
          if (insertErr) {
            return res.status(500).json({ message: 'Failed to create reset token', error: insertErr });
          }

          try {
            const transporter = nodemailer.createTransport({
              service: 'gmail',
              auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
              }
            });

            const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

            await transporter.sendMail({
              from: process.env.EMAIL_USER,
              to: email,
              subject: 'Reset Your Password',
              html: `
                <h2>Password Reset Request</h2>
                <p>You requested to reset your password.</p>
                <p>Click the link below to set a new password:</p>
                <a href="${resetLink}">${resetLink}</a>
                <p>This link will expire in 30 minutes.</p>
              `
            });

            res.json({ message: 'Password reset email sent successfully' });
          } catch (mailError) {
            res.status(500).json({ message: 'Failed to send email', error: mailError.message });
          }
        }
      );
    });
  });
};

exports.resetPassword = async (req, res) => {
  const { token, newPassword } = req.body;

  if (!token || !newPassword) {
    return res.status(400).json({ message: 'Token and new password are required' });
  }

  db.query(
    'SELECT * FROM password_resets WHERE token = ? AND expires_at > NOW()',
    [token],
    async (err, results) => {
      if (err) return res.status(500).json({ message: 'Database error', error: err });

      if (results.length === 0) {
        return res.status(400).json({ message: 'Invalid or expired reset token' });
      }

      const email = results[0].email;
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      db.query(
        'UPDATE users SET password = ? WHERE email = ?',
        [hashedPassword, email],
        (updateErr) => {
          if (updateErr) {
            return res.status(500).json({ message: 'Failed to update password', error: updateErr });
          }

          db.query('DELETE FROM password_resets WHERE email = ?', [email], (deleteErr) => {
            if (deleteErr) {
              return res.status(500).json({ message: 'Password updated but token cleanup failed', error: deleteErr });
            }

            res.json({ message: 'Password reset successfully' });
          });
        }
      );
    }
  );
};