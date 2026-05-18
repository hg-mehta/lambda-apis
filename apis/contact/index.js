/**
 * Lambda function to handle contact form submissions
 * Sends notifications to Slack via Incoming Webhook
 */

const https = require('https');
const url = require('url');

const MAX_MESSAGE_LENGTH = 2000;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Send message to Slack webhook
 */
function sendToSlack(webhookUrl, message) {
  return new Promise((resolve, reject) => {
    const parsedUrl = url.parse(webhookUrl);
    
    // Format message with Slack Block Kit for better presentation
    const payload = JSON.stringify({
      text: 'New Contact Form Submission',
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: '📧 New Contact Form Submission',
            emoji: true
          }
        },
        {
          type: 'section',
          fields: [
            {
              type: 'mrkdwn',
              text: `*Name:*\n${message.name}`
            },
            {
              type: 'mrkdwn',
              text: `*Email:*\n<mailto:${message.email}|${message.email}>`
            },
            {
              type: 'mrkdwn',
              text: `*Company:*\n${message.company || 'N/A'}`
            },
            {
              type: 'mrkdwn',
              text: `*Service Interest:*\n${message.service || 'N/A'}`
            }
          ]
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*Message:*\n${message.message}`
          }
        },
        {
          type: 'context',
          elements: [
            {
              type: 'mrkdwn',
              text: `⏰ ${new Date().toISOString()}`
            }
          ]
        }
      ]
    });

    const options = {
      hostname: parsedUrl.hostname,
      path: parsedUrl.path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve({ statusCode: res.statusCode, data });
        } else {
          reject(new Error(`Slack webhook returned status ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(payload);
    req.end();
  });
}

/**
 * Validate contact form data
 */
function validateInput(data) {
  const errors = [];

  if (!data.name || typeof data.name !== 'string' || data.name.trim().length === 0) {
    errors.push('Name is required');
  }

  if (!data.email || typeof data.email !== 'string' || !EMAIL_REGEX.test(data.email)) {
    errors.push('Valid email is required');
  }

  if (!data.message || typeof data.message !== 'string' || data.message.trim().length === 0) {
    errors.push('Message is required');
  }

  if (data.message && data.message.length > MAX_MESSAGE_LENGTH) {
    errors.push(`Message must be less than ${MAX_MESSAGE_LENGTH} characters`);
  }

  return errors;
}

/**
 * Lambda handler
 */
exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  // Handle CORS preflight
  if (event.requestContext?.http?.method === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Max-Age': '300'
      },
      body: JSON.stringify({ message: 'OK' })
    };
  }

  try {
    // Parse request body
    let body;
    try {
      body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    } catch (parseError) {
      console.error('Failed to parse request body:', parseError);
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ error: 'Invalid JSON in request body' })
      };
    }

    // Validate input
    const validationErrors = validateInput(body);
    if (validationErrors.length > 0) {
      console.error('Validation errors:', validationErrors);
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ error: validationErrors.join(', ') })
      };
    }

    // Get webhook URL from environment
    const webhookUrl = process.env.SLACK_WEBHOOK_URL;
    if (!webhookUrl) {
      console.error('SLACK_WEBHOOK_URL environment variable is not set');
      return {
        statusCode: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ error: 'Server configuration error' })
      };
    }

    // Prepare message for Slack
    const slackMessage = {
      name: body.name.trim(),
      email: body.email.trim(),
      company: body.company ? body.company.trim() : '',
      service: body.service ? body.service.trim() : '',
      message: body.message.trim()
    };

    // Send to Slack
    try {
      await sendToSlack(webhookUrl, slackMessage);
      console.log('Successfully sent message to Slack');

      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ message: 'Message sent successfully' })
      };
    } catch (slackError) {
      console.error('Failed to send message to Slack:', slackError);
      return {
        statusCode: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ error: 'Failed to send message' })
      };
    }
  } catch (error) {
    console.error('Unexpected error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};
