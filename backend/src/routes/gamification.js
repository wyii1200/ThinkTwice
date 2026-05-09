const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const db = admin.firestore();

    const [userDoc, leaderboardSnap] = await Promise.all([
      db.collection('users').doc(userId).get(),
      db.collection('users').orderBy('totalPoints', 'desc').limit(10).get(),
    ]);

    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });
    const user = userDoc.data();

    const leaderboard = leaderboardSnap.docs.map((doc, index) => ({
      rank:         index + 1,
      userId:       doc.id,
      displayName:  doc.data().displayName || 'Player',
      totalPoints:  doc.data().totalPoints || 0,
      streak:       doc.data().streak || 0,
      isCurrentUser: doc.id === userId,
    }));

    const nudgeSnap = await db.collection('nudgeLogs')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();

    const recentPointsEvents = nudgeSnap.docs
      .map(doc => {
        const d = doc.data();
        if (d.status === 'accepted') return { label: 'Saved from nudge', points: 10, type: 'save' };
        if (d.status === 'ignored')  return { label: 'Nudge ignored',    points: -2, type: 'ignore' };
        return null;
      })
      .filter(Boolean)
      .slice(0, 5);

    res.json({
      success: true,
      gamification: {
        streak:             user.streak             || 0,
        totalPoints:        user.totalPoints        || 0,
        resilienceScore:    user.resilienceScore    || 50,
        smartDecisionScore: user.smartDecisionScore || 50,
        leaderboard,
        badges:             evaluateBadges(user),
        quests:             buildQuests(user),
        recentPointsEvents,
      },
    });
  } catch (error) {
    console.error('Gamification error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/claim-quest', async (req, res) => {
  try {
    const { userId, questId } = req.body;
    if (!userId || !questId) return res.status(400).json({ error: 'Missing userId or questId' });

    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

    const user = userDoc.data();
    const quest = buildQuests(user).find(q => q.id === questId);

    if (!quest)            return res.status(404).json({ error: 'Quest not found' });
    if (!quest.isCompleted) return res.status(400).json({ error: 'Quest not completed yet' });
    if ((user.claimedQuests || []).includes(questId)) return res.status(409).json({ error: 'Already claimed' });

    await userRef.update({
      totalPoints:    admin.firestore.FieldValue.increment(quest.rewardPoints),
      claimedQuests:  admin.firestore.FieldValue.arrayUnion(questId),
    });

    res.json({ success: true, pointsAwarded: quest.rewardPoints });
  } catch (error) {
    console.error('Claim quest error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

function evaluateBadges(user) {
  const streak         = user.streak         || 0;
  const totalPoints    = user.totalPoints    || 0;
  const savingsPocket  = user.savingsPocket  || 0;
  const resilienceScore = user.resilienceScore || 50;
  return [
    { id: 'first_save',    title: 'First Save',       earned: savingsPocket > 0 },
    { id: 'streak_3',      title: '3-Day Streak',      earned: streak >= 3 },
    { id: 'streak_7',      title: 'Week Warrior',      earned: streak >= 7 },
    { id: 'resilience_70', title: 'Resilient',         earned: resilienceScore >= 70 },
    { id: 'points_500',    title: 'Point Collector',   earned: totalPoints >= 500 },
    { id: 'saver_100',     title: 'Century Saver',     earned: savingsPocket >= 100 },
  ];
}

function buildQuests(user) {
  const streak        = user.streak        || 0;
  const savingsPocket = user.savingsPocket || 0;
  const totalPoints   = user.totalPoints   || 0;
  const claimed       = user.claimedQuests || [];
  return [
    {
      id:            'quest_streak_3',
      title:         '3-Day Smart Streak',
      progress:      Math.min(streak / 3, 1),
      progressLabel: `${Math.min(streak, 3)} / 3 days`,
      rewardLabel:   '+50 pts',
      rewardPoints:  50,
      isCompleted:   streak >= 3,
      isClaimed:     claimed.includes('quest_streak_3'),
    },
    {
      id:            'quest_save_50',
      title:         'Save RM50',
      progress:      Math.min(savingsPocket / 50, 1),
      progressLabel: `RM${savingsPocket.toFixed(0)} / RM50`,
      rewardLabel:   '+80 pts',
      rewardPoints:  80,
      isCompleted:   savingsPocket >= 50,
      isClaimed:     claimed.includes('quest_save_50'),
    },
    {
      id:            'quest_points_200',
      title:         'Earn 200 Points',
      progress:      Math.min(totalPoints / 200, 1),
      progressLabel: `${totalPoints} / 200 pts`,
      rewardLabel:   'Streak Shield badge',
      rewardPoints:  0,
      isCompleted:   totalPoints >= 200,
      isClaimed:     claimed.includes('quest_points_200'),
    },
  ];
}

module.exports = router;