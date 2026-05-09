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

// Upvote a deal — switches from downvote if user previously downvoted
async function upvoteDeal(dealId, userId) {
  const ref = db.collection("deals").doc(dealId);

  const updated = await db.runTransaction(async (t) => {
    const doc = await t.get(ref);
    if (!doc.exists) throw new Error("Deal not found");

    const data = doc.data();
    const voters = data.voters || {};
    const existingVote = voters[userId];

    if (existingVote === "up") throw new Error("Already upvoted");

    let upvotesDelta = 1;
    let downvotesDelta = 0;
    let trustDelta = TRUST_UPVOTE;

    // Switching from downvote → upvote: reverse the downvote first
    if (existingVote === "down") {
      downvotesDelta = -1;
      trustDelta = TRUST_UPVOTE + TRUST_DOWNVOTE; // undo downvote + add upvote
    }

    const newUpvotes = Math.max(0, (data.upvotes || 0) + upvotesDelta);
    const newDownvotes = Math.max(0, (data.downvotes || 0) + downvotesDelta);
    const newTrustScore = Math.min(100, (data.trustScore || TRUST_INITIAL) + trustDelta);
    const isNowVerified = newTrustScore >= TRUST_VERIFIED_THRESHOLD;

    t.update(ref, {
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      trustScore: newTrustScore,
      verified: isNowVerified,
      hidden: false,
      [`voters.${userId}`]: "up",
    });

    return {
      trustScore: newTrustScore,
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      verified: isNowVerified,
      switched: existingVote === "down",
    };
  });

  return updated;
}

// Downvote a deal — switches from upvote if user previously upvoted
async function downvoteDeal(dealId, userId) {
  const ref = db.collection("deals").doc(dealId);

  const updated = await db.runTransaction(async (t) => {
    const doc = await t.get(ref);
    if (!doc.exists) throw new Error("Deal not found");

    const data = doc.data();
    const voters = data.voters || {};
    const existingVote = voters[userId];

    if (existingVote === "down") throw new Error("Already downvoted");

    // Prevent deal submitter from downvoting their own deal
    if (data.submittedBy === userId) throw new Error("Cannot downvote your own deal");

    let upvotesDelta = 0;
    let downvotesDelta = 1;
    let trustDelta = -TRUST_DOWNVOTE;

    // Switching from upvote → downvote: reverse the upvote first
    if (existingVote === "up") {
      upvotesDelta = -1;
      trustDelta = -(TRUST_DOWNVOTE + TRUST_UPVOTE); // undo upvote + add downvote
    }

    const newUpvotes = Math.max(0, (data.upvotes || 0) + upvotesDelta);
    const newDownvotes = Math.max(0, (data.downvotes || 0) + downvotesDelta);
    const newTrustScore = Math.max(0, (data.trustScore || TRUST_INITIAL) + trustDelta);
    const isHidden = newTrustScore < TRUST_HIDE_THRESHOLD;

    t.update(ref, {
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      trustScore: newTrustScore,
      hidden: isHidden,
      verified: false,
      [`voters.${userId}`]: "down",
    });

    return {
      trustScore: newTrustScore,
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      hidden: isHidden,
      switched: existingVote === "up",
    };
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