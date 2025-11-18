const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe?.secret_key || process.env.STRIPE_SECRET_KEY);

admin.initializeApp();

// Simple HTTP function to get vote results
exports.getVoteResults = functions.https.onRequest((req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).send('');
    return;
  }

  const db = admin.firestore();

  // Get all votes
  db.collection('voting')
    .doc('live_contest')
    .collection('user_votes')
    .get()
    .then((snapshot) => {
      if (snapshot.empty) {
        return res.status(200).send(`
          <html>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
              <h1>🏆 Live Contest Results</h1>
              <p>No votes found yet.</p>
            </body>
          </html>
        `);
      }

      // Count votes
      const voteCounts = {};
      let totalVotes = 0;

      snapshot.forEach((doc) => {
        const data = doc.data();
        const option = data.selectedOption;
        if (option) {
          voteCounts[option] = (voteCounts[option] || 0) + 1;
          totalVotes++;
        }
      });

      // Find winner
      let winner = null;
      let maxVotes = 0;
      for (const [option, count] of Object.entries(voteCounts)) {
        if (count > maxVotes) {
          maxVotes = count;
          winner = option;
        }
      }

      // Create HTML
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <title>Live Contest Results</title>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body {
              font-family: Arial, sans-serif;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              margin: 0;
              padding: 20px;
              min-height: 100vh;
            }
            .container {
              max-width: 800px;
              margin: 0 auto;
              background: white;
              border-radius: 20px;
              padding: 30px;
              box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            }
            .header {
              text-align: center;
              margin-bottom: 30px;
            }
            .title {
              color: #333;
              font-size: 2.5em;
              margin: 0;
              font-weight: bold;
            }
            .subtitle {
              color: #666;
              font-size: 1.2em;
              margin: 10px 0;
            }
            .winner {
              background: linear-gradient(45deg, #FFD700, #FFA500);
              color: white;
              padding: 20px;
              border-radius: 15px;
              margin: 20px 0;
              text-align: center;
              box-shadow: 0 10px 20px rgba(255, 215, 0, 0.3);
            }
            .winner h2 {
              margin: 0;
              font-size: 1.8em;
            }
            .winner p {
              margin: 10px 0 0 0;
              font-size: 1.2em;
            }
            .results {
              margin-top: 30px;
            }
            .result-item {
              display: flex;
              justify-content: space-between;
              align-items: center;
              padding: 15px;
              margin: 10px 0;
              background: #f8f9fa;
              border-radius: 10px;
              border-left: 5px solid #667eea;
            }
            .result-item.winner-item {
              background: linear-gradient(45deg, #FFD700, #FFA500);
              color: white;
              border-left: 5px solid #FF6B35;
            }
            .result-name {
              font-weight: bold;
              font-size: 1.1em;
            }
            .result-stats {
              text-align: right;
            }
            .result-votes {
              font-size: 1.3em;
              font-weight: bold;
              color: #667eea;
            }
            .result-percentage {
              color: #666;
              font-size: 0.9em;
            }
            .progress-bar {
              width: 100%;
              height: 8px;
              background: #e0e0e0;
              border-radius: 4px;
              margin: 5px 0;
              overflow: hidden;
            }
            .progress-fill {
              height: 100%;
              background: linear-gradient(45deg, #667eea, #764ba2);
              transition: width 0.3s ease;
            }
            .winner-item .progress-fill {
              background: linear-gradient(45deg, #FFD700, #FFA500);
            }
            .refresh-btn {
              background: #667eea;
              color: white;
              border: none;
              padding: 12px 24px;
              border-radius: 25px;
              cursor: pointer;
              font-size: 1em;
              margin: 20px 0;
              transition: background 0.3s ease;
            }
            .refresh-btn:hover {
              background: #5a6fd8;
            }
            .timestamp {
              text-align: center;
              color: #999;
              font-size: 0.9em;
              margin-top: 20px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1 class="title">🏆 Live Contest Results</h1>
              <p class="subtitle">Total Votes: ${totalVotes}</p>
            </div>
            
            ${winner ? `
              <div class="winner">
                <h2>🎉 Winner: ${winner}</h2>
                <p>${maxVotes} votes (${totalVotes > 0 ? ((maxVotes / totalVotes) * 100).toFixed(1) : 0}%)</p>
              </div>
            ` : ''}
            
            <div class="results">
              ${Object.entries(voteCounts)
                .sort(([,a], [,b]) => b - a)
                .map(([option, votes]) => {
                  const percentage = totalVotes > 0 ? ((votes / totalVotes) * 100).toFixed(1) : 0;
                  const isWinner = option === winner;
                  return `
                    <div class="result-item ${isWinner ? 'winner-item' : ''}">
                      <div class="result-name">${option}</div>
                      <div class="result-stats">
                        <div class="result-votes">${votes} votes</div>
                        <div class="result-percentage">${percentage}%</div>
                        <div class="progress-bar">
                          <div class="progress-fill" style="width: ${percentage}%"></div>
                        </div>
                      </div>
                    </div>
                  `;
                }).join('')}
            </div>
            
            <div style="text-align: center;">
              <button class="refresh-btn" onclick="location.reload()">🔄 Refresh Results</button>
            </div>
            
            <div class="timestamp">
              Last updated: ${new Date().toLocaleString()}
            </div>
          </div>
        </body>
        </html>
      `;

      res.status(200).send(html);
    })
    .catch((error) => {
      console.error('Error:', error);
      res.status(500).send(`
        <html>
          <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
            <h1>Error</h1>
            <p>Failed to get results: ${error.message}</p>
          </body>
        </html>
      `);
    });
});

// ============ BLACK FRIDAY BID PAYMENT FUNCTIONS ============

/**
 * Create a payment intent for a bid
 * This authorizes the payment but doesn't charge it
 */
exports.createBidPaymentIntent = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { amount, currency, bidId, offerId, userId } = data;

  // Validate input
  if (!amount || !bidId || !offerId || !userId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters'
    );
  }

  // Ensure user can only create payment intents for themselves
  if (context.auth.uid !== userId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'User can only create payment intents for themselves'
    );
  }

  try {
    // Create payment intent with manual capture
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency || 'usd',
      capture_method: 'manual',
      metadata: {
        bidId: bidId,
        offerId: offerId,
        userId: userId,
        type: 'black_friday_bid',
      },
    });

    return {
      paymentIntentId: paymentIntent.id,
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    console.error('Error creating payment intent:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to create payment intent: ${error.message}`
    );
  }
});

/**
 * Capture a payment intent (charge the card)
 * Called when a bid is accepted
 */
exports.captureBidPayment = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { paymentIntentId, bidId } = data;

  // Validate input
  if (!paymentIntentId || !bidId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters'
    );
  }

  try {
    // Retrieve the payment intent to verify metadata
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    // Verify this is a Black Friday bid payment
    if (paymentIntent.metadata.type !== 'black_friday_bid' || 
        paymentIntent.metadata.bidId !== bidId) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Invalid payment intent for this bid'
      );
    }

    // Capture the payment
    const captured = await stripe.paymentIntents.capture(paymentIntentId);

    // Log the transaction
    await admin.firestore()
      .collection('payment_logs')
      .add({
        type: 'bid_payment_captured',
        paymentIntentId: paymentIntentId,
        bidId: bidId,
        amount: captured.amount,
        currency: captured.currency,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    return {
      chargeId: captured.charges.data[0].id,
      amount: captured.amount,
    };
  } catch (error) {
    console.error('Error capturing payment:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to capture payment: ${error.message}`
    );
  }
});

/**
 * Cancel a payment intent
 * Called when a bid is rejected, outbid, or cancelled
 */
exports.cancelBidPaymentIntent = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { paymentIntentId, bidId } = data;

  // Validate input
  if (!paymentIntentId || !bidId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters'
    );
  }

  try {
    // Retrieve the payment intent to verify metadata
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    // Verify this is a Black Friday bid payment
    if (paymentIntent.metadata.type !== 'black_friday_bid' || 
        paymentIntent.metadata.bidId !== bidId) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Invalid payment intent for this bid'
      );
    }

    // Cancel the payment intent
    await stripe.paymentIntents.cancel(paymentIntentId);

    // Log the cancellation
    await admin.firestore()
      .collection('payment_logs')
      .add({
        type: 'bid_payment_cancelled',
        paymentIntentId: paymentIntentId,
        bidId: bidId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    return {
      success: true,
      message: 'Payment authorization cancelled',
    };
  } catch (error) {
    console.error('Error cancelling payment intent:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to cancel payment intent: ${error.message}`
    );
  }
});

/**
 * Refund a payment
 * Called if there's an issue after a payment has been captured
 */
exports.refundBidPayment = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { chargeId, bidId, reason } = data;

  // Validate input
  if (!chargeId || !bidId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters'
    );
  }

  try {
    // Create refund
    const refund = await stripe.refunds.create({
      charge: chargeId,
      reason: reason || 'requested_by_customer',
      metadata: {
        bidId: bidId,
        type: 'black_friday_bid_refund',
      },
    });

    // Log the refund
    await admin.firestore()
      .collection('payment_logs')
      .add({
        type: 'bid_payment_refunded',
        chargeId: chargeId,
        refundId: refund.id,
        bidId: bidId,
        amount: refund.amount,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    return {
      refundId: refund.id,
      amount: refund.amount,
    };
  } catch (error) {
    console.error('Error refunding payment:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to refund payment: ${error.message}`
    );
  }
});

/**
 * Scheduled function to automatically expire and cancel payment intents
 * for bids that weren't accepted by midnight
 */
exports.expireBidPayments = functions.pubsub
  .schedule('0 0 * * *') // Run at midnight every day
  .timeZone('America/New_York') // ET timezone
  .onRun(async (context) => {
    const db = admin.firestore();
    
    try {
      // Get yesterday's date key
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const months = ['January', 'February', 'March', 'April', 'May', 'June',
                     'July', 'August', 'September', 'October', 'November', 'December'];
      const dayKey = `${months[yesterday.getMonth()]} ${yesterday.getDate()}, ${yesterday.getFullYear()}`;

      // Get all pending bids from yesterday
      const bidsSnapshot = await db.collectionGroup('bids')
        .where('status', '==', 'pending')
        .where('bidType', '==', 'money')
        .get();

      const batch = db.batch();
      const cancelPromises = [];

      for (const bidDoc of bidsSnapshot.docs) {
        const bid = bidDoc.data();
        
        // Check if bid has a payment intent
        if (bid.paymentIntentId) {
          // Cancel the payment intent
          try {
            await stripe.paymentIntents.cancel(bid.paymentIntentId);
            console.log(`Cancelled payment intent for bid ${bidDoc.id}`);
          } catch (error) {
            console.error(`Error cancelling payment intent ${bid.paymentIntentId}:`, error);
          }
        }

        // Update bid status to expired
        batch.update(bidDoc.ref, { status: 'expired' });
      }

      await batch.commit();
      console.log(`Expired ${bidsSnapshot.size} bids`);

      return null;
    } catch (error) {
      console.error('Error expiring bid payments:', error);
      return null;
    }
  });
