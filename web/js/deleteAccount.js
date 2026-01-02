 import { auth, db, storage } from "./firebase-init.js";
  import { deleteUser } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
  import { doc, deleteDoc } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";
  import { ref, listAll, deleteObject } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-storage.js";

  // Enable delete button when checkbox is checked
  document.getElementById("confirmDelete").addEventListener("change", function() {
      document.getElementById("deleteBtn").disabled = !this.checked;
  });

  document.getElementById("deleteAccountForm").addEventListener("submit", async (e) => {
      e.preventDefault();

      const email = document.getElementById("email").value;
      const password = document.getElementById("password").value;
      const userType = document.getElementById("userType").value;
      const btn = document.getElementById("deleteBtn");

      hideError();
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner"></span>Deleting Account...';

      try {
          console.log("🔐 Signing in user...");
          const userCred = await signInWithEmailAndPassword(auth, email, password);
          const user = userCred.user;
          const userId = user.uid;

          console.log("✅ User authenticated");
          console.log("🗑️ Deleting user data for type:", userType);

          // Delete user data based on account type
          if (userType === "landlord") {
              await deleteLandlordData(userId);
          } else if (userType === "student") {
              await deleteStudentData(userId);
          } else if (userType === "driver") {
              await deleteDriverData(userId);
          }

          console.log("✅ User data deleted");
          console.log("🗑️ Deleting Firebase Auth account...");

          // Delete the Firebase Auth account
          await deleteUser(user);

          console.log("✅ Account deleted successfully!");
          showSuccess();

      } catch (error) {
          console.error("❌ Error:", error);
          let errorMessage = "Failed to delete account. Please try again.";

          if (error.code === "auth/wrong-password") {
              errorMessage = "Incorrect password. Please try again.";
          } else if (error.code === "auth/user-not-found") {
              errorMessage = "No account found with this email.";
          } else if (error.code === "auth/invalid-email") {
              errorMessage = "Invalid email address.";
          } else if (error.code === "auth/too-many-requests") {
              errorMessage = "Too many failed attempts. Please try again later.";
          } else if (error.code === "auth/requires-recent-login") {
              errorMessage = "For security reasons, please log out and log back in before deleting your account.";
          } else {
              errorMessage = error.message || errorMessage;
          }

          showError(errorMessage);
          btn.disabled = false;
          btn.innerHTML = "Delete My Account";
      }
  });

  async function deleteLandlordData(userId) {
      console.log("🏠 Deleting landlord data...");

      // Delete accommodations and their images
      const accSnap = await getDocs(query(collection(db, "Accommodation"), where("userId", "==", userId)));

      for (const accDoc of accSnap.docs) {
          console.log(`Deleting accommodation: ${accDoc.id}`);

          // Delete images subcollection
          const imagesRef = collection(db, "Accommodation", accDoc.id, "images");
          const imgSnap = await getDocs(imagesRef);

          for (const img of imgSnap.docs) {
              await deleteDoc(img.ref);
              // Optional: Delete from storage
              try {
                  const storageRef = ref(storage, `accommodations/${accDoc.id}/${img.id}`);
                  await deleteObject(storageRef);
              } catch (e) {
                  console.log("Storage file not found or already deleted");
              }
          }

          await deleteDoc(accDoc.ref);
      }

      // Delete user document
      await deleteDoc(doc(db, "Users", userId));
      console.log("✅ Landlord data deleted");
  }

  async function deleteStudentData(userId) {
      console.log("🎓 Deleting student data...");

      // Delete student form
      try {
          await deleteDoc(doc(db, "StudentForm", userId));
      } catch (e) {
          console.log("StudentForm not found or already deleted");
      }

      // Delete products and their images
      const prodSnap = await getDocs(query(collection(db, "products"), where("sellerId", "==", userId)));

      for (const prod of prodSnap.docs) {
          console.log(`Deleting product: ${prod.id}`);

          // Delete product images from storage
          try {
              const storageRef = ref(storage, `products/${prod.id}`);
              const files = await listAll(storageRef);
              for (const file of files.items) {
                  await deleteObject(file);
              }
          } catch (e) {
              console.log("Storage files not found or already deleted");
          }

          await deleteDoc(prod.ref);
      }

      // Delete user document
      await deleteDoc(doc(db, "Users", userId));
      console.log("✅ Student data deleted");
  }

  async function deleteDriverData(userId) {
      console.log("🚗 Deleting driver data...");

      // Delete vehicle document
      try {
          await deleteDoc(doc(db, "Vehicle", userId));
      } catch (e) {
          console.log("Vehicle not found or already deleted");
      }

      // Delete user document
      await deleteDoc(doc(db, "Users", userId));
      console.log("✅ Driver data deleted");
  }

  function showError(msg) {
      const alert = document.getElementById("errorAlert");
      alert.textContent = msg;
      alert.classList.remove("hidden");
      window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function hideError() {
      document.getElementById("errorAlert").classList.add("hidden");
  }

  function showSuccess() {
      document.getElementById("deleteForm").classList.add("hidden");
      document.getElementById("successMessage").classList.remove("hidden");
  }

  window.cancelDelete = function() {
      if (confirm("Are you sure you want to cancel? You will remain logged in.")) {
          window.close();
      }
  }

  window.togglePassword = function(id, btn) {
      const input = document.getElementById(id);
      const icon = btn.querySelector('i');
      if (input.type === 'password') {
          input.type = 'text';
          icon.classList.remove('fa-eye');
          icon.classList.add('fa-eye-slash');
      } else {
          input.type = 'password';
          icon.classList.remove('fa-eye-slash');
          icon.classList.add('fa-eye');
      }
  }