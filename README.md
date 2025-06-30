# NewsApp

Mobile Application built with Flutter.

**Demo Link:** [Watch on YouTube](https://youtu.be/jwuw23to_Ws)

---

## Features

- Like, Comment, Bookmark, and Share news articles
- Push Notifications (Foreground, Background, and Terminated states)
- Sign Up with Profile Picture Upload
- Toggle Button for Light/Dark Mode

---

## Technologies Used

- Flutter – UI Framework
- Firebase
  - Firestore Database
  - Firebase Authentication
- Provider – State Management Pattern
- Hive – Local storage (sync bookmarks when offline)
- Node.js – API for Push Notifications (hosted in a separate repo)
- NYTimes API – For fetching latest news
- Imgur API – For uploading and retrieving images

---

## App Preview

<p align="center">
  <img src="https://github.com/user-attachments/assets/1d511fe8-d9e5-4dca-9562-4bf014f0f620" width="250" style="margin: 10px"/>
  <img src="https://github.com/user-attachments/assets/ca0b7910-1340-4bd2-be82-9fb0f8e56e72" width="250" style="margin: 10px"/>
  <br/>
  <img src="https://github.com/user-attachments/assets/2b427ce5-7873-4fb6-9a24-7020f873edcf" width="250" style="margin: 10px"/>
  <img src="https://github.com/user-attachments/assets/49888530-e258-441b-9138-a1390ddf45b6" width="250" style="margin: 10px"/>
  <br/>
  <img src="https://github.com/user-attachments/assets/1c7398af-2717-4dc7-bce6-d96a70c0571d" width="250" style="margin: 10px"/>
  <img src="https://github.com/user-attachments/assets/2ac3f010-0d16-4685-8326-60cf94226e06" width="250" style="margin: 10px"/>
</p>

---

## How to Run

1. Clone the repository:
```bash
git clone https://github.com/yourusername/newsapp.git
cd newsapp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

> Note: Make sure you have configured Firebase correctly and added all required API keys before running the app.
