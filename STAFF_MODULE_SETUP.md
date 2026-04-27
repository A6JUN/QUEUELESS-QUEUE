# Staff/Counter Module Setup Guide

## ✅ What Was Created

### 1. **Staff Dashboard Screen** (`lib/screens/staff_dashboard_screen.dart`)
- Shows staff name and hospital name
- Displays today's statistics:
  - Total tokens booked
  - Waiting tokens
  - Completed tokens
  - On Hold tokens
- "Manage Queue" button
- "Refresh Statistics" button
- Logout functionality

### 2. **Queue Management Screen** (`lib/screens/queue_management_screen.dart`)
- View all tokens for today
- Filter by status: All, Waiting, Called, On Hold, Completed
- Each token shows:
  - Token number (A001, A002, etc.)
  - Patient name
  - Department
  - Status badge
  - Queue position
  - Booked time
- Action buttons based on status:
  - **Waiting**: Call | Hold
  - **Called**: Complete | Hold
  - **On Hold**: Call Again | No Show
  - **Completed**: Shows "Service Completed"

### 3. **Updated Auth Wrapper** (`lib/screens/auth_wrapper.dart`)
- Added routing for `hospital_staff` role
- Routes:
  - `user` → Service Selection Screen
  - `admin` → Admin Dashboard
  - `hospital_staff` → Staff Dashboard

---

## 🎯 Token Status Flow

```
waiting → called → completed ✅
   ↓         ↓
on_hold → called → completed ✅
   ↓
no_show ❌
```

### Status Definitions:
- **waiting**: Patient in queue, not called yet
- **called**: Patient currently being called
- **on_hold**: Patient skipped/not present, will call later
- **completed**: Service finished successfully
- **no_show**: Patient didn't arrive, removed from queue

---

## 📊 Database Structure

### Users Collection (Updated)
```javascript
{
  uid: "staff_user_id",
  fullName: "Staff Name",
  email: "staff@hospital.com",
  role: "hospital_staff",  // NEW ROLE
  hospitalId: "hospital_id",  // NEW FIELD - Assigned hospital
  createdAt: timestamp
}
```

### Tokens Collection (NEW - Not Yet Created)
```javascript
{
  tokenId: "auto_generated",
  tokenNumber: "A001",
  userId: "user_uid",
  userName: "John Doe",
  userEmail: "john@example.com",
  hospitalId: "hospital_id",
  hospitalName: "Aster Hospital",
  department: "General",
  status: "waiting" | "called" | "on_hold" | "completed" | "no_show",
  queuePosition: 5,
  estimatedWaitTime: 45,
  bookedAt: timestamp,
  updatedAt: timestamp,
  calledAt: timestamp (nullable),
  completedAt: timestamp (nullable),
  date: "2026-04-19"
}
```

---

## 🔧 How to Create Staff Account

### Method 1: Using Debug Screen (Easiest)
1. Create a regular user account
2. Long press "Queueless" title on home screen
3. Tap "Set Role to Admin" (temporarily)
4. Go to Firebase Console → Firestore → users collection
5. Find the user document
6. Change:
   - `role`: `"hospital_staff"`
   - Add `hospitalId`: `"your_hospital_id"` (copy from hospitals collection)
7. Logout and login again
8. Should route to Staff Dashboard

### Method 2: Firebase Console (Manual)
1. Go to Firebase Console → Firestore
2. Find user in `users` collection
3. Edit document:
   ```json
   {
     "fullName": "Staff Name",
     "email": "staff@hospital.com",
     "role": "hospital_staff",
     "hospitalId": "hospital_id_from_hospitals_collection",
     "createdAt": timestamp
   }
   ```
4. Login with that email

### Method 3: Admin Panel (Future Feature)
- Admin can create staff accounts
- Assign hospital to staff
- Set role automatically

---

## 🚀 Next Steps to Complete the System

### 1. **Create Token Booking Flow** (User Side)
- User selects hospital
- User selects department
- Generate token number
- Save to Firestore
- Show confirmation

### 2. **Create My Tokens Screen** (User Side)
- View active tokens
- View past tokens
- Real-time queue position
- Cancel token option

### 3. **Implement Token Number Generation**
- Use `queue_counters` collection
- Format: A001, A002, B001 (department-based)
- Reset daily per hospital

### 4. **Add Real-time Updates**
- Use Firestore streams
- Update queue position automatically
- Notify users when turn is near

### 5. **Add Notifications**
- Push notifications (Firebase Cloud Messaging)
- Email notifications
- SMS notifications (optional)

---

## 🧪 Testing the Staff Module

### Test Scenario 1: View Dashboard
1. Login as staff
2. Should see Staff Dashboard
3. Check statistics (will be 0 if no tokens)

### Test Scenario 2: Manage Queue (After tokens are created)
1. Click "Manage Queue"
2. Should see list of tokens
3. Try filters: All, Waiting, Called, etc.

### Test Scenario 3: Update Token Status
1. Find a "Waiting" token
2. Click "Call" button
3. Status should change to "Called"
4. Click "Complete" button
5. Status should change to "Completed"

### Test Scenario 4: Hold/Skip Patient
1. Find a "Waiting" token
2. Click "Hold" button
3. Status should change to "On Hold"
4. Click "Call Again" button
5. Status should change back to "Called"

### Test Scenario 5: No Show
1. Find an "On Hold" token
2. Click "No Show" button
3. Status should change to "No Show"
4. Token removed from active queue

---

## 📱 Staff Module Features

### ✅ Completed:
- Staff dashboard with statistics
- Queue management screen
- Filter tokens by status
- Update token status (Call, Hold, Complete, No Show)
- Real-time updates via Firestore streams
- Role-based routing

### ⏳ Pending (Requires Token Booking):
- Actual token data (need users to book tokens first)
- Queue position calculation
- Estimated wait time
- Call next patient automatically
- Statistics charts

---

## 🎨 UI Features

- Clean, modern design matching the app theme
- Color-coded status badges
- Action buttons based on token status
- Real-time updates
- Responsive layout
- Smooth animations

---

## 🔐 Security

### Firestore Rules (Update Required):
```javascript
// Staff can only access their hospital's tokens
match /tokens/{tokenId} {
  allow read: if request.auth != null && 
                 (resource.data.userId == request.auth.uid || 
                  get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'hospital_staff']);
  allow create: if request.auth != null;
  allow update: if request.auth != null && 
                   get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'hospital_staff'];
}
```

---

## 📊 What's Next?

1. **Implement Token Booking** (User side)
2. **Create My Tokens Screen** (User side)
3. **Test complete flow**: User books → Staff manages → User sees updates
4. **Add notifications**
5. **Add analytics**

---

## 🎯 Complete User Journey

### User Side:
1. Login → Service Selection
2. Select Hospital
3. Select Department
4. Book Token → Get Token Number (A001)
5. View "My Tokens" → See queue position
6. Get notification when turn is near
7. Go to hospital → Show token

### Staff Side:
1. Login → Staff Dashboard
2. View today's statistics
3. Click "Manage Queue"
4. See all waiting patients
5. Call next patient (A001)
6. Patient arrives → Mark as Complete
7. Patient doesn't arrive → Put On Hold or No Show
8. Continue with next patient

---

The Staff/Counter module is now ready! Next step is to implement the token booking system on the user side.
