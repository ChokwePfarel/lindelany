import { auth } from "./firebase-init.js";

    const urlParams = new URLSearchParams(window.location.search);
    const mode = urlParams.get('mode');
    const oobCode = urlParams.get('oobCode');

      if (!oobCode || mode !== 'resetPassword') {
        showError('Invalid or expired reset link. Please request a new password reset from the app.');
        document.getElementById('passwordForm').style.display = 'none';
      }

      document.getElementById('passwordForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        hideError();

        if (newPassword.length < 6) {
          showError('Password must be at least 6 characters long');
          return;
        }

        if (newPassword !== confirmPassword) {
          showError('Passwords do not match');
          return;
        }

        const btn = document.getElementById('resetBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner"></span>Resetting Password...';

        try {
          await auth.verifyPasswordResetCode(oobCode);
          await auth.confirmPasswordReset(oobCode, newPassword);
          showSuccess();
        } catch (error) {
          let msg = 'An error occurred. Please try again.';
          if (error.code === 'auth/expired-action-code') msg = 'This reset link has expired.';
          else if (error.code === 'auth/invalid-action-code') msg = 'Invalid reset link.';
          else if (error.code === 'auth/weak-password') msg = 'Password is too weak.';
          showError(msg);
          btn.disabled = false;
          btn.innerHTML = 'Reset Password';
        }
      });


      function (id, btn){
        const input = document.getElementById(id);
        const icon = btn.querySelector('i');
        if(input.type === 'password'){
          input.type = 'text';
          icon.classList.replace('fa-eye', 'fa-eye-slash');
        }else{
          input.type = 'password';
          icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
      }

      function togglePassword(id, btn) {
        const alert = document.getElementById('errorAlert');
        alert.textContent = msg;
        alert.classList.remove('hidden');
      }

      function hideError() {
        document.getElementById('errorAlert').classList.add('hidden');
      }

      function showSuccess() {
        document.getElementById('resetForm').classList.add('hidden');
        document.getElementById('successMessage').classList.remove('hidden');
      }

      function openApp() {
        const appLink = 'lindelany://';
        window.location.href = appLink;
        setTimeout(() => {
          alert('If the app doesn\'t open automatically, please open Lindelany manually.');
        }, 2000);
      }