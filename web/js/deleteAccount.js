import { auth, db, storage } from "./firebase-init.js";
import {
  signInWithEmailAndPassword,
  deleteUser
} from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
import {
  collection,
  query,
  where,
  getDocs,
  doc,
  deleteDoc
} from "https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";
import {
  ref,
  listAll,
  deleteObject
} from "https://www.gstatic.com/firebasejs/10.11.1/firebase-storage.js";

// DOM elements
const deleteAccountForm = document.getElementById('deleteAccountForm');
const successMessage    = document.getElementById('successMessage');
const errorAlert        = document.getElementById('errorAlert');
const deleteBtn         = document.getElementById('deleteBtn');
const confirmCheckbox   = document.getElementById('confirmDelete');

// Enable/disable delete button
if (confirmCheckbox) {
  confirmCheckbox.addEventListener('change', (e) => {
    deleteBtn.disabled = !e.target.checked;
  });
}

// Global functions for HTML
window.togglePassword = function (id, btn) {
  const input = document.getElementById(id);
  const icon  = btn.querySelector('i');
  if (input.type === 'password') {
    input.type = 'text';
    if (icon) icon.classList.replace('fa-eye', 'fa-eye-slash');
  } else {
    input.type = 'password';
    if (icon) icon.classList.replace('fa-eye-slash', 'fa-eye');
  }
};

window.cancelDelete = function () {
  window.location.href = 'index.html';
};

// Form submission
if (deleteAccountForm) {
  deleteAccountForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const email    = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const userType = document.getElementById('userType').value; // from HTML: landlord, student, driver

    if (!confirmCheckbox.checked) return;

    hideError();
    setLoading(true);

    try {
      console.log("--- Starting Account Deletion ---");

      // 1. Re-authenticate
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user   = userCredential.user;
      const userId = user.uid;

      console.log("Authenticated UID:", userId);

      // 2. Perform data cleanup based on type (Adopting Flutter logic)
      const type = userType.toLowerCase();

      if (type === 'landlord') {
        await deleteLandlordData(userId);
      } else if (type === 'student') {
        await deleteStudentData(userId);
      } else if (type === 'transportation') {
        await deleteTransportationData(userId);
      } else {
        throw new Error("Invalid account type selected.");
      }

      // 3. Delete the Auth user
      console.log("Deleting Auth user...");
      await deleteUser(user);

      console.log("Deletion complete.");
      showSuccess();

    } catch (error) {
      console.error("Deletion failed:", error);
      let msg = "Error: " + error.message;

      if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
        msg = "Incorrect email or password. Please verify your credentials.";
      } else if (error.code === 'auth/requires-recent-login') {
        msg = "For security, please log out and log back in before deleting your account.";
      } else if (error.code === 'auth/user-not-found') {
        msg = "No account found with this email.";
      }

      showError(msg);
    } finally {
      setLoading(false);
    }
  });
}

// ── LANDLORD Logic ───────────────────────────────────────────────────────────
async function deleteLandlordData(userId) {
  console.log("Cleaning Landlord data...");

  // Find all accommodations for this user
  const accQuery = query(collection(db, "Accommodation"), where("userId", "==", userId));
  const accSnap  = await getDocs(accQuery);
  console.log(`Found ${accSnap.size} accommodations.`);

  for (const accDoc of accSnap.docs) {
    const accId = accDoc.id;

    // Delete 'images' subcollection and corresponding storage files
    const imgSnap = await getDocs(collection(db, "Accommodation", accId, "images"));
    for (const img of imgSnap.docs) {
      await deleteDoc(img.ref);
      try {
        // Path matches Flutter: accommodations/{accId}/{imgId}
        await deleteObject(ref(storage, `accommodations/${accId}/${img.id}`));
      } catch (e) { console.warn("Storage skip:", img.id); }
    }

    // Delete the accommodation doc
    await deleteDoc(accDoc.ref);
  }

  // Delete main user record
  await deleteDoc(doc(db, "Users", userId));
}

// ── STUDENT Logic ────────────────────────────────────────────────────────────
async function deleteStudentData(userId) {
  console.log("Cleaning Student data...");

  // 1. Delete StudentForm
  const sfSnap = await getDocs(query(collection(db, "StudentForm"), where("userId", "==", userId)));
  for (const d of sfSnap.docs) {
    await deleteDoc(d.ref);
  }

  // 2. Delete products and their storage files
  const prodSnap = await getDocs(query(collection(db, "products"), where("userId", "==", userId)));
  for (const prod of prodSnap.docs) {
    try {
      const folderRef = ref(storage, `products/${prod.id}`);
      const files = await listAll(folderRef);
      for (const item of files.items) {
        await deleteObject(item);
      }
    } catch (e) { console.warn("Product storage skip:", prod.id); }

    await deleteDoc(prod.ref);
  }

  // 3. Delete main user record
  await deleteDoc(doc(db, "Users", userId));
}

// ── TRANSPORTATION Logic ──────────────────────────────────────────────────────
async function deleteTransportationData(userId) {
  console.log("Cleaning Transportation data...");

  // Delete Vehicle records
  const vSnap = await getDocs(query(collection(db, "Vehicle"), where("userId", "==", userId)));
  for (const d of vSnap.docs) {
    await deleteDoc(d.ref);
  }

  // Delete main user record
  await deleteDoc(doc(db, "Users", userId));
}

// ── UI Helpers ────────────────────────────────────────────────────────────────
function setLoading(isLoading) {
  if (deleteBtn) {
    if (isLoading) {
      deleteBtn.disabled = true;
      deleteBtn.innerHTML = '<span class="spinner"></span>Processing...';
    } else {
      deleteBtn.disabled = !confirmCheckbox.checked;
      deleteBtn.innerHTML = 'Delete My Account';
    }
  }
}

function showError(msg) {
  if (errorAlert) {
    errorAlert.textContent = msg;
    errorAlert.classList.remove('hidden');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function hideError() {
  if (errorAlert) errorAlert.classList.add('hidden');
}

function showSuccess() {
  const formDiv = document.getElementById('deleteForm');
  if (formDiv) formDiv.classList.add('hidden');
  if (successMessage) successMessage.classList.remove('hidden');
}
