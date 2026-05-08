const { db } = require("../firebase");

const TRUST_INITIAL = 50;
const TRUST_UPVOTE = 5;
const TRUST_DOWNVOTE = 5;
const TRUST_VERIFIED_THRESHOLD = 70;
const TRUST_HIDE_THRESHOLD = 20;

// Called when a deal is first submitted
function getInitialTrustScore() {
  return TRUST_INITIAL;
}

// Upvote a deal — returns updated trust score
// Prevents duplicate votes from same user
async function upvoteDeal(dealId, userId) {
  const ref = db.collection("deals").doc(dealId);

  const updated = await db.runTransaction(async (t) => {
    const doc = await t.get(ref);
    if (!doc.exists) throw new Error("Deal not found");

    const data = doc.data();

    // Check if user already voted
    const voters = data.voters || {};
    if (voters[userId]) {
      throw new Error(voters[userId] === "up" ? "Already upvoted" : "Switch your downvote first");
    }

    const newUpvotes = (data.upvotes || 0) + 1;
    const newTrustScore = Math.min(100, (data.trustScore || TRUST_INITIAL) + TRUST_UPVOTE);
    const isNowVerified = newTrustScore >= TRUST_VERIFIED_THRESHOLD;

    t.update(ref, {
      upvotes: newUpvotes,
      trustScore: newTrustScore,
      verified: isNowVerified,
      [`voters.${userId}`]: "up",
    });

    return { trustScore: newTrustScore, upvotes: newUpvotes, verified: isNowVerified };
  });

  return updated;
}

// Downvote a deal — returns updated trust score
// Prevents duplicate votes from same user
async function downvoteDeal(dealId, userId) {
  const ref = db.collection("deals").doc(dealId);

  const updated = await db.runTransaction(async (t) => {
    const doc = await t.get(ref);
    if (!doc.exists) throw new Error("Deal not found");

    const data = doc.data();

    // Check if user already voted
    const voters = data.voters || {};
    if (voters[userId]) {
      throw new Error(voters[userId] === "down" ? "Already downvoted" : "Switch your upvote first");
    }

    // Prevent deal submitter from downvoting their own deal
    if (data.submittedBy === userId) {
      throw new Error("Cannot downvote your own deal");
    }

    const newDownvotes = (data.downvotes || 0) + 1;
    const newTrustScore = Math.max(0, (data.trustScore || TRUST_INITIAL) - TRUST_DOWNVOTE);
    const isHidden = newTrustScore < TRUST_HIDE_THRESHOLD;

    t.update(ref, {
      downvotes: newDownvotes,
      trustScore: newTrustScore,
      hidden: isHidden,
      verified: false,
      [`voters.${userId}`]: "down",
    });

    return { trustScore: newTrustScore, downvotes: newDownvotes, hidden: isHidden };
  });

  return updated;
}

// Check if deal should be shown (above hide threshold)
function isDealVisible(trustScore) {
  return trustScore >= TRUST_HIDE_THRESHOLD;
}

// Check if deal is verified
function isDealVerified(trustScore) {
  return trustScore >= TRUST_VERIFIED_THRESHOLD;
}

module.exports = {
  getInitialTrustScore,
  upvoteDeal,
  downvoteDeal,
  isDealVisible,
  isDealVerified,
  TRUST_VERIFIED_THRESHOLD,
};