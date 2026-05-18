// Fuel cost estimate in Malaysia (RM per km, RON95 average)
const FUEL_COST_PER_KM = 0.15;
 
// Estimate fuel cost for a route
function estimateTravelCost(distanceKm) {
  return parseFloat((distanceKm * FUEL_COST_PER_KM).toFixed(2));
}
 
// Calculate net savings after accounting for travel cost
// dealSaving: how much cheaper the deal is vs user's usual spend
// distanceKm: how far user needs to travel to get the deal
function calculateNetSavings(dealSavingRM, distanceKm) {
  const travelCost = estimateTravelCost(distanceKm);
  const netSaving = parseFloat((dealSavingRM - travelCost).toFixed(2));
  return {
    grossSavingRM: dealSavingRM,
    travelCostRM: travelCost,
    netSavingRM: netSaving,
    worthIt: netSaving > 0,
  };
}
 
// Calculate total savings for the month from savings_proof collection records
function aggregateMonthlySavings(savingsProofRecords) {
  const totalSaved = savingsProofRecords.reduce((sum, r) => sum + (r.amountSaved || 0), 0);
  const byType = {};
 
  for (const record of savingsProofRecords) {
    const type = record.type || "unknown";
    byType[type] = (byType[type] || 0) + (record.amountSaved || 0);
  }
 
  return {
    totalSavedRM: parseFloat(totalSaved.toFixed(2)),
    byType,
    recordCount: savingsProofRecords.length,
    records: savingsProofRecords,
  };
}
 
// Record a savings event to Firestore
async function recordSavingsProof(db, userId, { type, amountSaved, category, dealId = null, routeId = null ,dealTitle = ''}) {
  const now = new Date();
  const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;
 
  const proofRef = db.collection("savings_proof").doc();
  await proofRef.set({
    proofId: proofRef.id,
    userId,
    type,           // "route_used" | "deal_used" | "nudge_accepted"
    amountSaved,
    category,
    dealId,
    routeId,
    month,
    createdAt: new Date().toISOString(),
    dealTitle: dealTitle || '',
  });
 
  return proofRef.id;
}
 
module.exports = { estimateTravelCost, calculateNetSavings, aggregateMonthlySavings, recordSavingsProof };