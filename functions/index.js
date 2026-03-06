const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * AI Analysis Cloud Function
 * Triggered on-demand or scheduled to analyze user transactions
 * and generate insights.
 */
exports.analyzeUserFinances = functions.https.onCall(async (data, context) => {
    // Auth check
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated."
        );
    }

    const uid = context.auth.uid;
    const userDoc = await db.collection("users").doc(uid).get();

    if (!userDoc.exists) {
        throw new functions.https.HttpsError("not-found", "User not found.");
    }

    const userData = userDoc.data();
    const transactions = userData.transactions || [];
    const profile = userData.profile || {};
    const monthlyIncome = profile.income || 0;
    const budgets = profile.budgets || {};

    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    // Filter this month's transactions
    const thisMonth = transactions.filter((t) => {
        const d = new Date(t.date);
        return d.getMonth() === currentMonth && d.getFullYear() === currentYear;
    });

    const expenses = thisMonth.filter((t) => t.type === "expense");
    const incomes = thisMonth.filter((t) => t.type === "income");

    const totalExpense = expenses.reduce((s, t) => s + (t.amount || 0), 0);
    const totalIncome = incomes.reduce((s, t) => s + (t.amount || 0), 0);

    const insights = [];

    // ─── 1. Emotional Spending Detection ───
    const foodSpend = expenses
        .filter((t) => t.category === "Food")
        .reduce((s, t) => s + t.amount, 0);

    const shoppingSpend = expenses
        .filter((t) => t.category === "Shopping")
        .reduce((s, t) => s + t.amount, 0);

    // 3-month average for comparison
    const threeMonthsAgo = new Date(now);
    threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);

    const prevFood = transactions
        .filter((t) => {
            const d = new Date(t.date);
            return t.type === "expense" && t.category === "Food" &&
                d >= threeMonthsAgo && d.getMonth() !== currentMonth;
        })
        .reduce((s, t) => s + t.amount, 0);

    const avgFood = prevFood / 3;
    if (avgFood > 0 && foodSpend > avgFood * 1.5) {
        insights.push({
            id: generateId(),
            type: "emotional",
            title: "Food Spending Spike 🍔",
            message: `Your food spending is ${Math.round((foodSpend / avgFood - 1) * 100)}% above your 3-month average.`,
            severity: "warning",
            generatedAt: now.toISOString(),
            metadata: { current: foodSpend, average: avgFood },
        });
    }

    // ─── 2. Overspending Prediction ───
    const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
    const dayOfMonth = now.getDate();
    const projectionFactor = daysInMonth / dayOfMonth;

    for (const [category, limit] of Object.entries(budgets)) {
        const spent = expenses
            .filter((t) => t.category === category)
            .reduce((s, t) => s + t.amount, 0);

        const projected = spent * projectionFactor;
        const probability = Math.min((projected / limit) * 100, 100);

        if (probability > 80) {
            insights.push({
                id: generateId(),
                type: "prediction",
                title: `${category} Budget Alert`,
                message: `You are ${Math.round(probability)}% likely to exceed your ${category} budget this month.`,
                severity: probability > 100 ? "critical" : "warning",
                generatedAt: now.toISOString(),
                metadata: { category, spent, limit, projected },
            });
        }
    }

    // ─── 3. Financial Personality Classification ───
    const savingsRatio = totalIncome > 0 ? (totalIncome - totalExpense) / totalIncome : 0;
    const nonEssential = ["Shopping", "Entertainment", "Food"];
    const nonEssentialSpend = expenses
        .filter((t) => nonEssential.includes(t.category))
        .reduce((s, t) => s + t.amount, 0);
    const nonEssentialRatio = totalExpense > 0 ? nonEssentialSpend / totalExpense : 0;

    let personality;
    if (savingsRatio > 0.3) personality = "Safe Saver";
    else if (nonEssentialRatio > 0.6) personality = "Impulse Buyer";
    else if (nonEssentialRatio > 0.4) personality = "Social Spender";
    else personality = "Risk Taker";

    insights.push({
        id: generateId(),
        type: "personality",
        title: "Your Financial Personality",
        message: `You are a ${personality}.`,
        severity: "info",
        generatedAt: now.toISOString(),
        metadata: { personality, savingsRatio, nonEssentialRatio },
    });

    // ─── 4. Spending Alert ───
    if (monthlyIncome > 0 && totalExpense > monthlyIncome * 0.9) {
        insights.push({
            id: generateId(),
            type: "tip",
            title: "Spending Alert 🚨",
            message: `You've spent ${Math.round((totalExpense / monthlyIncome) * 100)}% of your income. Consider cutting non-essentials.`,
            severity: "critical",
            generatedAt: now.toISOString(),
        });
    }

    // Save insights to subcollection
    const batch = db.batch();
    for (const insight of insights) {
        const ref = db
            .collection("users")
            .doc(uid)
            .collection("aiInsights")
            .doc(insight.id);
        batch.set(ref, insight);
    }
    await batch.commit();

    return { insights, count: insights.length };
});

/**
 * Gamification Check - runs after transaction write
 */
exports.checkGamification = functions.firestore
    .document("users/{uid}")
    .onUpdate(async (change, context) => {
        const uid = context.params.uid;
        const after = change.after.data();
        const transactions = after.transactions || [];
        const gamification = after.gamification || { points: 0, badges: [] };
        const profile = after.profile || {};
        const income = profile.income || 0;

        const badges = new Set(gamification.badges || []);
        let points = gamification.points || 0;

        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();

        const thisMonth = transactions.filter((t) => {
            const d = new Date(t.date);
            return d.getMonth() === currentMonth && d.getFullYear() === currentYear;
        });

        const monthExpense = thisMonth
            .filter((t) => t.type === "expense")
            .reduce((s, t) => s + t.amount, 0);
        const monthIncome = thisMonth
            .filter((t) => t.type === "income")
            .reduce((s, t) => s + t.amount, 0);

        // Badge: Saved 10% income
        if (income > 0 && (monthIncome - monthExpense) >= income * 0.1) {
            if (!badges.has("Smart Saver")) {
                badges.add("Smart Saver");
                points += 50;
            }
        }

        // Badge: 100 transactions
        if (transactions.length >= 100 && !badges.has("Century Club")) {
            badges.add("Century Club");
            points += 100;
        }

        // Points: +5 per transaction added
        const before = change.before.data();
        const prevCount = (before.transactions || []).length;
        const newCount = transactions.length;
        if (newCount > prevCount) {
            points += (newCount - prevCount) * 5;
        }

        // Budget discipline check
        const budgets = profile.budgets || {};
        let allWithinBudget = Object.keys(budgets).length > 0;
        for (const [cat, limit] of Object.entries(budgets)) {
            const spent = thisMonth
                .filter((t) => t.type === "expense" && t.category === cat)
                .reduce((s, t) => s + t.amount, 0);
            if (spent > limit) allWithinBudget = false;
        }
        if (allWithinBudget && Object.keys(budgets).length > 0 && !badges.has("Budget Master")) {
            badges.add("Budget Master");
            points += 75;
        }

        await db.collection("users").doc(uid).update({
            "gamification.points": points,
            "gamification.badges": Array.from(badges),
        });
    });

function generateId() {
    return "ins_" + Math.random().toString(36).substring(2, 15) +
        Math.random().toString(36).substring(2, 15);
}
