import { initializeApp } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyDLLrczfn4Ry4Gi_vJ81PeEM3w_VsOqCsI",
  authDomain: "patience-da636.firebaseapp.com",
  projectId: "patience-da636",
  storageBucket: "patience-da636.firebasestorage.app",
  messagingSenderId: "423113472279",
  appId: "1:423113472279:web:f60e643f6aa381c1e85f52",
  measurementId: "G-EJ5GY6QYF5"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
