const functions = require('firebase-functions');
const admin = require('firebase-admin');

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

