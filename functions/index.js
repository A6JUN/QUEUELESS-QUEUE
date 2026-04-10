const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function triggered when a new user is created
 * Sends a welcome email to the newly registered user
 */
exports.sendWelcomeEmail = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  const displayName = user.displayName || 'User';
  
  // Log the trigger
  console.log(`New user created: ${email}`);
  
  // Validate email exists
  if (!email) {
    console.error('User email is undefined');
    return null;
  }

  try {
    // Send welcome email
    await sendEmail(email, displayName);
    console.log(`Welcome email sent successfully to ${email}`);
    return null;
  } catch (error) {
    console.error('Error sending welcome email:', error);
    // Don't throw error - we don't want to block user creation
    return null;
  }
});

/**
 * Sends welcome email using Nodemailer with Gmail SMTP
 * @param {string} recipientEmail - User's email address
 * @param {string} displayName - User's display name
 */
async function sendEmail(recipientEmail, displayName) {
  // Get email configuration from environment variables
  const gmailEmail = functions.config().gmail?.email;
  const gmailPassword = functions.config().gmail?.password;

  // Validate configuration
  if (!gmailEmail || !gmailPassword) {
    throw new Error('Gmail credentials not configured. Run: firebase functions:config:set gmail.email="your-email" gmail.password="your-app-password"');
  }

  // Create transporter with Gmail SMTP
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: gmailEmail,
      pass: gmailPassword,
    },
  });

  // Email content
  const mailOptions = {
    from: `Queueless Queue <${gmailEmail}>`,
    to: recipientEmail,
    subject: 'Welcome to Queueless Queue 🎉',
    html: generateEmailHTML(recipientEmail, displayName),
    text: generateEmailText(recipientEmail, displayName),
  };

  // Send email
  const info = await transporter.sendMail(mailOptions);
  console.log('Email sent:', info.messageId);
  return info;
}

/**
 * Generates HTML email content
 * @param {string} email - User's email
 * @param {string} name - User's name
 * @returns {string} HTML email content
 */
function generateEmailHTML(email, name) {
  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Welcome to Queueless Queue</title>
    </head>
    <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc;">
      <table role="presentation" style="width: 100%; border-collapse: collapse;">
        <tr>
          <td align="center" style="padding: 40px 0;">
            <table role="presentation" style="width: 600px; max-width: 100%; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
              
              <!-- Header with gradient -->
              <tr>
                <td style="background: linear-gradient(135deg, #4F46E5 0%, #3B82F6 100%); padding: 40px 30px; text-align: center; border-radius: 16px 16px 0 0;">
                  <h1 style="margin: 0; color: #ffffff; font-size: 32px; font-weight: bold;">
                    Welcome to Queueless Queue! 🎉
                  </h1>
                </td>
              </tr>
              
              <!-- Main content -->
              <tr>
                <td style="padding: 40px 30px;">
                  <p style="margin: 0 0 20px; color: #1e293b; font-size: 16px; line-height: 1.6;">
                    Hi <strong>${name}</strong>,
                  </p>
                  
                  <p style="margin: 0 0 20px; color: #1e293b; font-size: 16px; line-height: 1.6;">
                    Thank you for joining <strong>Queueless Queue</strong>! We're excited to have you on board.
                  </p>
                  
                  <p style="margin: 0 0 30px; color: #1e293b; font-size: 16px; line-height: 1.6;">
                    With Queueless Queue, you can <strong>skip the line and save your time</strong> at hospitals, banks, government offices, and more.
                  </p>
                  
                  <!-- Features box -->
                  <table role="presentation" style="width: 100%; border-collapse: collapse; background-color: #f8fafc; border-radius: 12px; padding: 20px; margin-bottom: 30px;">
                    <tr>
                      <td style="padding: 20px;">
                        <h2 style="margin: 0 0 15px; color: #4F46E5; font-size: 20px;">What you can do:</h2>
                        <ul style="margin: 0; padding-left: 20px; color: #64748b; font-size: 15px; line-height: 1.8;">
                          <li>Book appointments at hospitals</li>
                          <li>Reserve slots at banks</li>
                          <li>Schedule visits to government offices</li>
                          <li>Track your queue position in real-time</li>
                          <li>Get notified when it's your turn</li>
                        </ul>
                      </td>
                    </tr>
                  </table>
                  
                  <p style="margin: 0 0 20px; color: #1e293b; font-size: 16px; line-height: 1.6;">
                    Your account is now active and ready to use. Simply log in with your email:
                  </p>
                  
                  <p style="margin: 0 0 30px; color: #4F46E5; font-size: 16px; font-weight: bold;">
                    ${email}
                  </p>
                  
                  <p style="margin: 0; color: #64748b; font-size: 14px; line-height: 1.6;">
                    If you have any questions or need assistance, feel free to reach out to our support team.
                  </p>
                </td>
              </tr>
              
              <!-- Footer -->
              <tr>
                <td style="background-color: #f8fafc; padding: 30px; text-align: center; border-radius: 0 0 16px 16px; border-top: 1px solid #e2e8f0;">
                  <p style="margin: 0 0 10px; color: #64748b; font-size: 14px;">
                    <strong>Queueless Queue</strong>
                  </p>
                  <p style="margin: 0 0 10px; color: #64748b; font-size: 13px;">
                    Skip the line. Save your time.
                  </p>
                  <p style="margin: 0; color: #94a3b8; font-size: 12px;">
                    © ${new Date().getFullYear()} Queueless Queue. All rights reserved.
                  </p>
                </td>
              </tr>
              
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
  `;
}

/**
 * Generates plain text email content (fallback)
 * @param {string} email - User's email
 * @param {string} name - User's name
 * @returns {string} Plain text email content
 */
function generateEmailText(email, name) {
  return `
Welcome to Queueless Queue! 🎉

Hi ${name},

Thank you for joining Queueless Queue! We're excited to have you on board.

With Queueless Queue, you can skip the line and save your time at hospitals, banks, government offices, and more.

What you can do:
- Book appointments at hospitals
- Reserve slots at banks
- Schedule visits to government offices
- Track your queue position in real-time
- Get notified when it's your turn

Your account is now active and ready to use. Simply log in with your email: ${email}

If you have any questions or need assistance, feel free to reach out to our support team.

---
Queueless Queue
Skip the line. Save your time.
© ${new Date().getFullYear()} Queueless Queue. All rights reserved.
  `;
}
