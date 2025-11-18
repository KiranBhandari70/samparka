import nodemailer from "nodemailer";
import config from "../config/config.js";

/**
 * Email sending utility
 * Handles email sending using nodemailer
 */

// Create reusable transporter
let transporter = null;

/**
 * Initialize email transporter
 * @returns {Object} Nodemailer transporter
 */
const getTransporter = () => {
  if (transporter) {
    return transporter;
  }

  // Email configuration from environment variables
  const emailConfig = {
    host: process.env.SMTP_HOST || "smtp.gmail.com",
    port: parseInt(process.env.SMTP_PORT) || 587,
    secure: process.env.SMTP_SECURE === "true", // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  };

  // If using Gmail with app password or OAuth2
  if (process.env.SMTP_SERVICE === "gmail") {
    transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });
  } else {
    transporter = nodemailer.createTransport(emailConfig);
  }

  return transporter;
};

/**
 * Send email
 * @param {Object} options - Email options
 * @param {string} options.to - Recipient email address
 * @param {string} options.subject - Email subject
 * @param {string} options.text - Plain text email body
 * @param {string} options.html - HTML email body
 * @param {Array} options.attachments - Email attachments
 * @param {string} options.from - Sender email (optional, uses default if not provided)
 * @returns {Promise<Object>} Email sending result
 */
export const sendEmail = async (options) => {
  try {
    const { to, subject, text, html, attachments, from } = options;

    if (!to || !subject) {
      throw new Error("Recipient email and subject are required");
    }

    const transporter = getTransporter();

    // Default from address
    const defaultFrom = process.env.SMTP_FROM || process.env.SMTP_USER || "noreply@samparka.com";

    const mailOptions = {
      from: from || defaultFrom,
      to: Array.isArray(to) ? to.join(", ") : to,
      subject,
      text: text || "",
      html: html || text || "",
      attachments: attachments || []
    };

    const info = await transporter.sendMail(mailOptions);

    return {
      success: true,
      messageId: info.messageId,
      response: info.response
    };
  } catch (error) {
    console.error("Error sending email:", error);
    throw new Error(`Failed to send email: ${error.message}`);
  }
};

/**
 * Send verification email
 * @param {string} to - Recipient email
 * @param {string} verificationToken - Verification token
 * @param {string} userName - User name
 * @returns {Promise<Object>} Email sending result
 */
export const sendVerificationEmail = async (to, verificationToken, userName = "User") => {
  const verificationUrl = `${process.env.FRONTEND_URL || "http://localhost:3000"}/verify-email?token=${verificationToken}`;

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .button { display: inline-block; padding: 12px 24px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { margin-top: 30px; font-size: 12px; color: #666; }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>Email Verification</h2>
        <p>Hello ${userName},</p>
        <p>Thank you for registering with Samparka. Please verify your email address by clicking the button below:</p>
        <a href="${verificationUrl}" class="button">Verify Email</a>
        <p>Or copy and paste this link into your browser:</p>
        <p>${verificationUrl}</p>
        <p>This link will expire in 24 hours.</p>
        <div class="footer">
          <p>If you didn't create an account, please ignore this email.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
    Hello ${userName},
    
    Thank you for registering with Samparka. Please verify your email address by visiting:
    ${verificationUrl}
    
    This link will expire in 24 hours.
    
    If you didn't create an account, please ignore this email.
  `;

  return sendEmail({
    to,
    subject: "Verify Your Email Address - Samparka",
    text,
    html
  });
};

/**
 * Send password reset email
 * @param {string} to - Recipient email
 * @param {string} resetToken - Password reset token
 * @param {string} userName - User name
 * @returns {Promise<Object>} Email sending result
 */
export const sendPasswordResetEmail = async (to, resetToken, userName = "User") => {
  const resetUrl = `${process.env.FRONTEND_URL || "http://localhost:3000"}/reset-password?token=${resetToken}`;

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .button { display: inline-block; padding: 12px 24px; background-color: #dc3545; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { margin-top: 30px; font-size: 12px; color: #666; }
        .warning { background-color: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>Password Reset Request</h2>
        <p>Hello ${userName},</p>
        <p>We received a request to reset your password. Click the button below to reset it:</p>
        <a href="${resetUrl}" class="button">Reset Password</a>
        <p>Or copy and paste this link into your browser:</p>
        <p>${resetUrl}</p>
        <div class="warning">
          <p><strong>Important:</strong> This link will expire in 1 hour. If you didn't request a password reset, please ignore this email.</p>
        </div>
        <div class="footer">
          <p>If you didn't request this, please secure your account immediately.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
    Hello ${userName},
    
    We received a request to reset your password. Visit this link to reset it:
    ${resetUrl}
    
    This link will expire in 1 hour.
    
    If you didn't request a password reset, please ignore this email.
  `;

  return sendEmail({
    to,
    subject: "Password Reset Request - Samparka",
    text,
    html
  });
};

/**
 * Send welcome email
 * @param {string} to - Recipient email
 * @param {string} userName - User name
 * @returns {Promise<Object>} Email sending result
 */
export const sendWelcomeEmail = async (to, userName) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .button { display: inline-block; padding: 12px 24px; background-color: #28a745; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>Welcome to Samparka!</h2>
        <p>Hello ${userName},</p>
        <p>Welcome to Samparka! We're excited to have you join our community.</p>
        <p>Get started by exploring events, joining groups, and connecting with people in your area.</p>
        <a href="${process.env.FRONTEND_URL || "http://localhost:3000"}" class="button">Get Started</a>
        <p>If you have any questions, feel free to reach out to our support team.</p>
        <p>Best regards,<br>The Samparka Team</p>
      </div>
    </body>
    </html>
  `;

  const text = `
    Hello ${userName},
    
    Welcome to Samparka! We're excited to have you join our community.
    
    Get started by exploring events, joining groups, and connecting with people in your area.
    
    Visit: ${process.env.FRONTEND_URL || "http://localhost:3000"}
    
    If you have any questions, feel free to reach out to our support team.
    
    Best regards,
    The Samparka Team
  `;

  return sendEmail({
    to,
    subject: "Welcome to Samparka!",
    text,
    html
  });
};

/**
 * Send verification status email
 * @param {string} to - Recipient email
 * @param {string} status - Verification status (approved/rejected)
 * @param {string} userName - User name
 * @param {string} reason - Rejection reason (optional)
 * @returns {Promise<Object>} Email sending result
 */
export const sendVerificationStatusEmail = async (to, status, userName = "User", reason = null) => {
  const isApproved = status === "approved";
  const statusColor = isApproved ? "#28a745" : "#dc3545";
  const statusText = isApproved ? "Approved" : "Rejected";

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .status-box { padding: 20px; border-radius: 5px; margin: 20px 0; background-color: ${isApproved ? "#d4edda" : "#f8d7da"}; }
        .status-text { color: ${statusColor}; font-weight: bold; font-size: 18px; }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>Verification Status Update</h2>
        <p>Hello ${userName},</p>
        <div class="status-box">
          <p class="status-text">Your verification request has been ${statusText}</p>
          ${!isApproved && reason ? `<p><strong>Reason:</strong> ${reason}</p>` : ""}
        </div>
        ${isApproved ? "<p>Congratulations! Your account is now verified. You can now access all verified user features.</p>" : "<p>If you believe this is an error, please contact our support team.</p>"}
        <p>Best regards,<br>The Samparka Team</p>
      </div>
    </body>
    </html>
  `;

  const text = `
    Hello ${userName},
    
    Your verification request has been ${statusText}.
    ${!isApproved && reason ? `Reason: ${reason}` : ""}
    
    ${isApproved ? "Congratulations! Your account is now verified." : "If you believe this is an error, please contact our support team."}
    
    Best regards,
    The Samparka Team
  `;

  return sendEmail({
    to,
    subject: `Verification ${statusText} - Samparka`,
    text,
    html
  });
};

/**
 * Test email configuration
 * @returns {Promise<boolean>} Success status
 */
export const testEmailConfig = async () => {
  try {
    const transporter = getTransporter();
    await transporter.verify();
    console.log("Email configuration is valid");
    return true;
  } catch (error) {
    console.error("Email configuration error:", error);
    return false;
  }
};

export default {
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendVerificationStatusEmail,
  testEmailConfig
};

