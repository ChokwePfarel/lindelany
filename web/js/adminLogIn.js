import { auth, db, storage } from "./firebase-init.js";
import { signInWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
import { collection, query, orderBy, doc, updateDoc, deleteDoc, getDoc,
limit, startAfter, getDocs, getCountFromServer, limitToLast, endBefore } from
"https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";
import { getFunctions, httpsCallable } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-functions.js";
import { ref, deleteObject } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-storage.js";
import { getApp } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js";

const app = getApp();
const functions = getFunctions(app);
let currentRejectDoc = null;

// Pagination state
const ITEMS_PER_PAGE = 20;
let currentPage = 1;
let totalCount = 0;
let firstVisibleDoc = null;
let lastVisibleDoc = null;
let pageHistory = []; // Stack to store first doc of each page for back navigation


// Add this utility function at the top of your file
function showSuccessToast(message) {
    const toast = document.createElement('div');
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #10b981, #059669);
        color: white;
        padding: 16px 24px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        z-index: 10000;
        font-weight: 600;
        animation: slideIn 0.3s ease-out;
    `;

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-in';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Add these CSS animations to your stylesheet
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

/* ------------------------------------------------------------------
   ADMIN ACCESS CONTROL – ONLY ADMINS CAN USE THE DASHBOARD
------------------------------------------------------------------ */

auth.onAuthStateChanged(async (user) => {
    console.log("Auth state changed:", user ? user.email : "No user");

    if (!user) {
        showLogin();
        return;
    }

    try {
        // Refresh auth token to pull latest custom claims
        const tokenResult = await user.getIdTokenResult(true);
        console.log("Token claims:", tokenResult.claims);

        if (!tokenResult.claims.admin) {
            // User is NOT admin
            alert("Access denied – Admins only.");
            await auth.signOut();
            return;
        }

        // User is admin → show dashboard
        showDashboard(user);

        // Wait a moment for token to propagate to Firestore
        setTimeout(() => {
            loadVerifications();
        }, 500);
    } catch (error) {
        console.error("Error checking admin status:", error);
        alert("Error verifying admin status: " + error.message);
        await auth.signOut();
    }
});

/* ------------------------------------------------------------------
    LOGIN FUNCTION
------------------------------------------------------------------ */

document.getElementById("loginForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    console.log("Login form submitted");

    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value;
    const loginBtn = document.getElementById("loginBtn");
    const errorDiv = document.getElementById("loginError");

    console.log("Attempting login for:", email);

    loginBtn.disabled = true;
    loginBtn.textContent = "Signing in...";
    errorDiv.innerHTML = "";

    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        console.log("Login successful:", userCredential.user.email);
        // Auth state change will handle the rest
    } catch (error) {
        console.error("Login error:", error);
        errorDiv.innerHTML = `<div class="error-message">${error.message}</div>`;
        loginBtn.disabled = false;
        loginBtn.textContent = "Sign In";
    }
});

/* ------------------------------------------------------------------
   LOGOUT
------------------------------------------------------------------ */
document.getElementById("logoutBtn").addEventListener("click", () => {
    console.log("Logging out");
    auth.signOut();
});

/* ------------------------------------------------------------------
   SHOW/HIDE UI SCREENS
------------------------------------------------------------------ */
function showLogin() {
    console.log("Showing login screen");
    document.getElementById("loginScreen").style.display = "flex";
    document.getElementById("dashboardScreen").style.display = "none";
}

function showDashboard(user) {
    console.log("Showing dashboard for:", user.email);
    document.getElementById("loginScreen").style.display = "none";
    document.getElementById("dashboardScreen").style.display = "block";
    document.getElementById("userEmail").textContent = user.email;
}

/* ------------------------------------------------------------------
   LOAD VERIFICATIONS WITH EFFICIENT CURSOR-BASED PAGINATION
------------------------------------------------------------------ */

async function loadVerifications() {
    console.log("Loading verifications...");

    // Ensure we're using the latest auth token
    if (auth.currentUser) {
        try {
            await auth.currentUser.getIdToken(true);
            console.log("Token refreshed");
        } catch (error) {
            console.error("Error refreshing token:", error);
        }
    }

    // Get total count
    try {
        const verificationsRef = collection(db, "awaitVerification");
        const snapshot = await getCountFromServer(verificationsRef);
        totalCount = snapshot.data().count;
        document.getElementById("pendingCount").textContent = totalCount;
        console.log("Total verifications:", totalCount);
    } catch (error) {
        console.error("Error getting count:", error);
    }

    // Reset pagination state and load first page
    currentPage = 1;
    pageHistory = [];
    firstVisibleDoc = null;
    lastVisibleDoc = null;

    loadCurrentPage();
}

async function loadCurrentPage() {
    console.log("Loading page:", currentPage);
    const grid = document.getElementById("verificationGrid");
    const loadingState = document.getElementById("loadingState");
    const emptyState = document.getElementById("emptyState");

    loadingState.style.display = "block";
    grid.innerHTML = "";

    const verificationsRef = collection(db, "awaitVerification");
    const q = query(
        verificationsRef,
        orderBy("submittedAt", "desc"),
        limit(ITEMS_PER_PAGE)
    );

    try {
        const snapshot = await getDocs(q);
        loadingState.style.display = "none";

        if (snapshot.empty) {
            emptyState.style.display = "block";
            document.getElementById("paginationControls").style.display = "none";
            return;
        }

        emptyState.style.display = "none";

        // Store first and last docs for navigation
        firstVisibleDoc = snapshot.docs[0];
        lastVisibleDoc = snapshot.docs[snapshot.docs.length - 1];

        // Render cards
        snapshot.forEach((docSnap) => {
            const data = docSnap.data();
            const card = createVerificationCard(docSnap.id, data);
            grid.appendChild(card);
        });

        // Update pagination controls
        updatePaginationControls();

    } catch (error) {
        console.error("Error loading page:", error);
        loadingState.style.display = "none";
        emptyState.style.display = "block";
        document.getElementById("emptyState").innerHTML = `
            <h2>Error Loading Verifications</h2>
            <p>${error.message}</p>
        `;
    }
}

async function loadNextPage() {
    if (!lastVisibleDoc) return;

    console.log("Loading next page");
    const grid = document.getElementById("verificationGrid");
    const loadingState = document.getElementById("loadingState");

    loadingState.style.display = "block";
    grid.innerHTML = "";

    const verificationsRef = collection(db, "awaitVerification");
    const q = query(
        verificationsRef,
        orderBy("submittedAt", "desc"),
        startAfter(lastVisibleDoc),
        limit(ITEMS_PER_PAGE)
    );

    try {
        const snapshot = await getDocs(q);
        loadingState.style.display = "none";

        if (snapshot.empty) {
            console.log("No more documents");
            return;
        }

        // Save current first doc to history before moving forward
        pageHistory.push(firstVisibleDoc);

        // Update cursors
        firstVisibleDoc = snapshot.docs[0];
        lastVisibleDoc = snapshot.docs[snapshot.docs.length - 1];
        currentPage++;

        // Render cards
        snapshot.forEach((docSnap) => {
            const data = docSnap.data();
            const card = createVerificationCard(docSnap.id, data);
            grid.appendChild(card);
        });

        updatePaginationControls();

    } catch (error) {
        console.error("Error loading next page:", error);
        loadingState.style.display = "none";
    }
}

async function loadPreviousPage() {
    if (pageHistory.length === 0) return;

    console.log("Loading previous page");
    const grid = document.getElementById("verificationGrid");
    const loadingState = document.getElementById("loadingState");

    loadingState.style.display = "block";
    grid.innerHTML = "";

    // Get the first doc of the previous page from history
    const previousFirstDoc = pageHistory.pop();

    const verificationsRef = collection(db, "awaitVerification");
    const q = query(
        verificationsRef,
        orderBy("submittedAt", "desc"),
        startAfter(previousFirstDoc),
        limit(ITEMS_PER_PAGE)
    );

    try {
        const snapshot = await getDocs(q);
        loadingState.style.display = "none";

        if (snapshot.empty) {
            console.log("No documents found");
            return;
        }

        // Update cursors
        firstVisibleDoc = snapshot.docs[0];
        lastVisibleDoc = snapshot.docs[snapshot.docs.length - 1];
        currentPage--;

        // Render cards
        snapshot.forEach((docSnap) => {
            const data = docSnap.data();
            const card = createVerificationCard(docSnap.id, data);
            grid.appendChild(card);
        });

        updatePaginationControls();

    } catch (error) {
        console.error("Error loading previous page:", error);
        loadingState.style.display = "none";
    }
}

function updatePaginationControls() {
    const paginationControls = document.getElementById("paginationControls");
    const totalPages = Math.ceil(totalCount / ITEMS_PER_PAGE);

    if (totalPages <= 1) {
        paginationControls.style.display = "none";
        return;
    }

    paginationControls.style.display = "flex";

    const startItem = (currentPage - 1) * ITEMS_PER_PAGE + 1;
    const endItem = Math.min(currentPage * ITEMS_PER_PAGE, totalCount);

    paginationControls.innerHTML = `
        <button data-action="prev" ${currentPage === 1 ? 'disabled' : ''}>← Previous</button>
        <span class="page-info">
            Showing ${startItem}-${endItem} of ${totalCount} | Page ${currentPage} of ${totalPages}
        </span>
        <button data-action="next" ${currentPage >= totalPages ? 'disabled' : ''}>Next →</button>
    `;
}

// Event delegation for pagination controls (set up once)
document.getElementById("paginationControls").addEventListener("click", (e) => {
    const button = e.target.closest("button");
    if (!button) return;

    const action = button.dataset.action;
    if (action === "prev" && currentPage > 1) {
        loadPreviousPage();
    } else if (action === "next") {
        loadNextPage();
    }
});

/* ------------------------------------------------------------------
   CREATE VERIFICATION CARD
------------------------------------------------------------------ */

function createVerificationCard(docId, data) {
    const card = document.createElement("div");
    card.className = "verification-card";

    const date = data.submittedAt?.toDate().toLocaleDateString() || "N/A";

    card.innerHTML = `
        <img src="${data.proofImage}" class="card-image" data-image="${data.proofImage}" alt="Proof image">
        <div class="card-content">
            <h3 class="card-title">${data.accommodationName || "Unnamed Accommodation"}</h3>
            <div class="card-info"><strong>Address:</strong> ${data.address}</div>
            <div class="card-info"><strong>City:</strong> ${data.city}</div>
            <div class="card-info"><strong>Postal Code:</strong> ${data.postalCode}</div>
            <div class="card-info"><strong>Email:</strong> ${data.userEmail}</div>
            <div class="card-info"><strong>Submitted:</strong> ${date}</div>
            <div class="card-actions">
                <button class="btn-approve"
                    data-id="${docId}"
                    data-accommodation="${data.accommodationId}"
                    data-userid="${data.userId}"
                    data-name="${data.accommodationName || 'your accommodation'}">
                    ✓ Approve
                </button>
                <button class="btn-reject"
                    data-id="${docId}"
                    data-email="${data.userEmail}"
                    data-name="${data.accommodationName || 'your accommodation'}"
                    data-userid="${data.userId}">
                    ✗ Reject
                </button>
            </div>
        </div>
    `;

    // Image modal
    card.querySelector(".card-image").addEventListener("click", (e) => {
        document.getElementById("modalImage").src = e.target.dataset.image;
        document.getElementById("imageModal").classList.add("active");
    });

    // Approve
    card.querySelector(".btn-approve").addEventListener("click", (e) => {
        handleApprove(
            e.target.dataset.id,
            e.target.dataset.accommodation,
            e.target.dataset.userid,
            e.target.dataset.name,
            e.target
        );
    });

    // Reject
    card.querySelector(".btn-reject").addEventListener("click", (e) => {
        currentRejectDoc = {
            id: e.target.dataset.id,
            email: e.target.dataset.email,
            name: e.target.dataset.name,
            userId: e.target.dataset.userid,
            button: e.target
        };
        document.getElementById("rejectModal").classList.add("active");
        document.getElementById("rejectReason").value = "";
    });

    return card;
}

/* ------------------------------------------------------------------
   APPROVE HANDLER - WITH FCM NOTIFICATION
------------------------------------------------------------------ */
async function handleApprove(docId, accommodationId, userId, accommodationName, btn) {
    if (!confirm("Approve this verification?")) return;

    const card = btn.closest('.verification-card');

    btn.disabled = true;
    btn.textContent = "Approving...";

    try {
        // 1. Update accommodation (critical operation)
        const accommodationRef = doc(db, "Accommodation", accommodationId);
        await updateDoc(accommodationRef, {
            isVerified: true,
            verificationStatus: "verified",
            verifiedAt: new Date(),
            verifiedBy: auth.currentUser.email
        });

        // 2. INSTANT UI UPDATE - Don't wait for cleanup
        card.style.transition = 'opacity 0.3s, transform 0.3s';
        card.style.opacity = '0';
        card.style.transform = 'scale(0.95)';

        // Update count immediately
        const currentCount = parseInt(document.getElementById("pendingCount").textContent);
        document.getElementById("pendingCount").textContent = currentCount - 1;

        // Show success toast (better than alert - non-blocking)
        showSuccessToast("✅ Verification approved!");

        // Remove card after animation
        setTimeout(() => card.remove(), 300);

        // Check if grid is now empty
        setTimeout(() => {
            const grid = document.getElementById("verificationGrid");
            if (grid.children.length === 0) {
                document.getElementById("emptyState").style.display = "block";
            }
        }, 350);

        // 3. Background cleanup (non-blocking) - user doesn't wait for this
        performBackgroundCleanup(docId, userId, accommodationName);

    } catch (err) {
        console.error("❌ Approval error:", err);
        alert("Error: " + err.message);
        btn.disabled = false;
        btn.textContent = "✓ Approve";
    }
}

// Background cleanup function - runs independently
async function performBackgroundCleanup(docId, userId, accommodationName) {
    const cleanupPromises = [];

    // Notification
    cleanupPromises.push(
        (async () => {
            try {
                const tokenResult = await auth.currentUser.getIdTokenResult(true);
                if (!tokenResult.claims.admin) {
                    console.warn("Admin claim not found");
                    return;
                }

                const freshFunctions = getFunctions(app);
                const sendNotification = httpsCallable(freshFunctions, 'sendVerificationNotification');

                const result = await sendNotification({
                    userId: userId,
                    type: 'approved',
                    accommodationName: accommodationName
                });

                console.log("✅ Notification sent:", result.data);
            } catch (error) {
                console.error("⚠️ Notification error (non-critical):", error);
            }
        })()
    );

    // Storage delete
    cleanupPromises.push(
        (async () => {
            try {
                const imagePath = `proofs/${userId}_proof.jpg`;
                const imageRef = ref(storage, imagePath);
                await deleteObject(imageRef);
                console.log("✅ Proof image deleted");
            } catch (error) {
                console.error("⚠️ Image deletion error (non-critical):", error);
            }
        })()
    );

    // Firestore delete
    cleanupPromises.push(
        (async () => {
            try {
                const verificationRef = doc(db, "awaitVerification", docId);
                await deleteDoc(verificationRef);
                console.log("✅ Verification document deleted");
            } catch (error) {
                console.error("⚠️ Firestore deletion error:", error);
            }
        })()
    );

    await Promise.allSettled(cleanupPromises);
    console.log("🧹 Background cleanup completed");
}
/* ------------------------------------------------------------------
   REJECTION LOGIC - WITH FCM NOTIFICATION
------------------------------------------------------------------ */

document.getElementById("sendReject").addEventListener("click", async () => {
    const reason = document.getElementById("rejectReason").value.trim();
    if (!reason) {
        alert("Please enter a rejection reason.");
        return;
    }

    if (!currentRejectDoc) return;

    const { id, userId, name, button } = currentRejectDoc;
    const card = button.closest('.verification-card');

    button.disabled = true;
    button.textContent = "Rejecting...";

    try {
        // 1. Close modal immediately
        document.getElementById("rejectModal").classList.remove("active");

        // 2. INSTANT UI UPDATE
        card.style.transition = 'opacity 0.3s, transform 0.3s';
        card.style.opacity = '0';
        card.style.transform = 'scale(0.95)';

        // Update count immediately
        const currentCount = parseInt(document.getElementById("pendingCount").textContent);
        document.getElementById("pendingCount").textContent = currentCount - 1;

        // Show success toast
        showSuccessToast("❌ Verification rejected!");

        // Remove card after animation
        setTimeout(() => card.remove(), 300);

        // Check if grid is now empty
        setTimeout(() => {
            const grid = document.getElementById("verificationGrid");
            if (grid.children.length === 0) {
                document.getElementById("emptyState").style.display = "block";
            }
        }, 350);

        currentRejectDoc = null;

        // 3. Background cleanup (non-blocking)
        performBackgroundRejectionCleanup(id, userId, name, reason);

    } catch (err) {
        console.error("❌ Rejection error:", err);
        alert("Error: " + err.message);
        button.disabled = false;
        button.textContent = "✗ Reject";
    }
});

// Background cleanup for rejection
async function performBackgroundRejectionCleanup(docId, userId, accommodationName, reason) {
    const cleanupPromises = [];

    // Notification
    cleanupPromises.push(
        (async () => {
            try {
                const tokenResult = await auth.currentUser.getIdTokenResult(true);
                if (!tokenResult.claims.admin) {
                    console.warn("Admin claim not found");
                    return;
                }

                const freshFunctions = getFunctions(app);
                const sendNotification = httpsCallable(freshFunctions, 'sendVerificationNotification');

                const result = await sendNotification({
                    userId: userId,
                    type: 'rejected',
                    accommodationName: accommodationName,
                    reason: reason
                });

                console.log("✅ Notification sent:", result.data);
            } catch (error) {
                console.error("⚠️ Notification error (non-critical):", error);
            }
        })()
    );

    // Storage delete
    cleanupPromises.push(
        (async () => {
            try {
                const imagePath = `proofs/${userId}_proof.jpg`;
                const imageRef = ref(storage, imagePath);
                await deleteObject(imageRef);
                console.log("✅ Proof image deleted");
            } catch (error) {
                console.error("⚠️ Image deletion error (non-critical):", error);
            }
        })()
    );

    // Firestore delete
    cleanupPromises.push(
        (async () => {
            try {
                const verificationRef = doc(db, "awaitVerification", docId);
                await deleteDoc(verificationRef);
                console.log("✅ Verification document deleted");
            } catch (error) {
                console.error("⚠️ Firestore deletion error:", error);
            }
        })()
    );

    await Promise.allSettled(cleanupPromises);
    console.log("🧹 Background cleanup completed");
}

document.getElementById("cancelReject").addEventListener("click", () => {
    document.getElementById("rejectModal").classList.remove("active");
    currentRejectDoc = null;
});

/* ------------------------------------------------------------------
   IMAGE MODAL CLOSE
------------------------------------------------------------------ */
document.getElementById("closeImageModal").onclick = () =>
    document.getElementById("imageModal").classList.remove("active");

document.getElementById("imageModal").onclick = (e) => {
    if (e.target.id === "imageModal") {
        document.getElementById("imageModal").classList.remove("active");
    }
};