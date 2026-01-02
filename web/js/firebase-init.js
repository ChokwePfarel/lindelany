import { initializeApp } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyCBGgjB8Y7euN9NJVtzLpwhypS_2nlFVy4",
  authDomain: "patience-da636.firebaseapp.com",
  projectId: "patience-da636",
  storageBucket: "patience-da636.firebasestorage.app",
  messagingSenderId: "423113472279",
  appId: "1:423113472279:android:e307f648e4c76765e85f52"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);


/*
For web

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-storage.js";
import { getFunctions } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-functions.js";

const firebaseConfig = {
  apiKey: "AIzaSyDLLrczfn4Ry4Gi_vJ81PeEM3w_VsOqCsI",
  authDomain: "patience-da636.firebaseapp.com",
  projectId: "patience-da636",
  storageBucket: "patience-da636.firebasestorage.app", // you confirmed this is correct
  messagingSenderId: "423113472279",
  appId: "1:423113472279:web:f60e643f6aa381c1e85f52", // Web appId
  measurementId: "G-EJ5GY6QYF5" // optional, only if you enabled Analytics
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export const functions = getFunctions(app); // add this if you plan to call callable functions

*/
