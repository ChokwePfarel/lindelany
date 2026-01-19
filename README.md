# Linde  
Student Living, Simplified

Linde is a full-stack mobile application built to improve student life by combining
student accommodation, a local marketplace, and student-powered transport services
into one platform.

The app connects students, landlords, and student transport providers in a verified,
safe, and efficient ecosystem designed specifically for university communities.

---

## 🔗 Links

- 📱 App Demo (Video): [ADD LINK HERE]
- 🖼️ Screenshots: [ADD LINK HERE]
- 🌐 Landing Page (optional): [ADD LINK HERE]

---

## 🎯 Problem Statement

Many students struggle to find safe and affordable accommodation and are often exposed
to scams and unreliable listings.

In addition, students frequently need to buy, sell, or transport goods but lack a
trusted, local platform to do so. At the same time, students with vehicles have limited
ways to monetize their availability.

Linde was built to solve these problems by creating a verified, student-focused platform
that supports housing, local trading, and income opportunities.

---

## 🚀 Features

### 🏠 Student Accommodation
- Browse verified student accommodation listings
- Direct in-app chat with landlords
- No agents or middlemen
- Reduced risk of scams through verification

### 📢 Broadcast System (Buy, Sell & Transport)
Students can create broadcasts to:
- Buy or sell goods (furniture, appliances, textbooks, etc.)
- Request transport for moving items
- Reach nearby students instantly

### 🚚 Student Transport & Side Hustles
- Students with cars or bakkies can view transport requests
- Respond directly to broadcasts
- Assist with moving goods
- Earn extra income while on campus

### 💬 Real-Time Chat
- Secure real-time messaging
- Used for accommodation inquiries and broadcast responses
- Designed for fast, direct communication

### 🔐 Authentication & User Roles
- Firebase Authentication
- Role-based access:
  - Student
  - Landlord
  - Transport Provider
- Feature access controlled by user role

### 📦 Offline Support
- Local caching using Hive
- Offline access to recent chats and data where available
- Improved performance and user experience

---

## 🧠 Architecture & Design Decisions

- **Flutter** was chosen for cross-platform development and rapid iteration
- **Firebase** provides scalable backend services and real-time data
- **Provider** is used for predictable and maintainable state management
- **Hive** enables offline-first behavior and local caching
- Business logic is separated from UI to improve maintainability and testability
- Services are modularized (auth, chat, notifications, payments)

---

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase
  - Firestore
  - Firebase Authentication
  - Firebase Storage
  - Firebase Cloud Functions
- **State Management:** Provider
- **Local Storage:** Hive
- **Notifications:** Firebase Cloud Messaging (FCM)
- **Payments:** Yoco (integration in progress / optional)

---

## 📱 Supported Platforms

- Android  
- iOS (planned)

---

## 📂 Project Structure (High-Level Overview)

<img width="388" height="566" alt="image" src="https://github.com/user-attachments/assets/32e022a1-4dbe-4238-86b1-8da44187f9ca" />
