# 🧵 Thread Cutting Manager
Thread Cutting Manager is a lightweight production tracking solution designed for garment and textile businesses.

A cross-platform application built with **Flutter** and **Supabase** to track, manage, and monitor cloth cutting records and vendors.  
Designed for **Admin** and **Supervisor** roles with role-based access control..

## Live Demo 
https://github.com/user-attachments/assets/dab667bb-8833-4015-a488-47221697aacc
<br>

## Screen Shots
<img width="380" height="800" alt="CutFlow Splash Screen" src="https://github.com/user-attachments/assets/658f929b-96b1-4b07-8da3-f320ed160555" />
<img width="380" height="800" alt="CutFLow Login Screen" src="https://github.com/user-attachments/assets/f09161da-b637-4e66-9614-1d5eb33ecb1b" />
<img width="380" height="800" alt="Cut Flow Main Screen" src="https://github.com/user-attachments/assets/e94ccfee-25e5-4ccb-86bb-980dea1ed59e" />


<br><br>
It allows:<br>
Tracking cloth pieces sent for cutting
Monitoring return status
Managing vendors
Assigning clear roles (Admin / Supervisor)
Built with Flutter, it runs seamlessly on Android and Web, with a shared Supabase backend.
Ideal for:
Small factories
Job work tracking
Outsourced cutting operations

Benefits:
Zero paperwork
Real-time visibility
Secure role-based access
Fast and scalable

## 🚀 Features

### 🔐 Authentication
- Email & Password login using **Supabase Auth**
- Persistent login session
- Role-based access (Admin / Supervisor)

### 📊 Dashboard
- Total Records
- Sent Records
- Pending Records
- Received Records

### 🧾 Records Management
- Add new cutting records
- Edit existing records (pre-filled form)
- Update status (Sent / Returned)
- Auto date handling (sent, expected, received)
- Delete records (Admin only)
- Vendor name joined with records

### 🏭 Vendor Management
- Add vendors
- Edit vendor details
- Delete vendors (Admin only)

### 🔍 Search
- Search records and vendors instantly

### 🌐 Multi-Platform
- Android
- Web (deployed on Vercel)
- iOS ready

---

## 🛠 Tech Stack

| Layer | Technology |
|------|-----------|
| UI | Flutter (Material UI) |
| Backend | Supabase |
| Database | PostgreSQL |
| Auth | Supabase Auth |
| Hosting (Web) | Vercel |

---

## 📂 Project Structure

```txt
lib/
│
├── app.dart
├── main.dart
│
├── data/
│   ├── auth_repository.dart
│   ├── record_repository.dart
│   └── vendor_repository.dart
│
├── models/
│   ├── record.dart
│   └── vendor.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── main_screen.dart
│   ├── records_tab.dart
│   └── vendors_tab.dart
│
├── widgets/
│   ├── dashboard_card.dart
│   ├── record_card.dart
│   └── vendor_card.dart

```

👨‍💻 Author
Nandan Gogari
Flutter | Android | Supabase
