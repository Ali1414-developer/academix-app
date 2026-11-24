# AcademiX – AI-Powered Teaching Assistant (Flutter Frontend)

A complete, responsive, strictly frontend **Flutter & Dart** mobile application built with Material Design 3, Google Fonts (`Poppins`), `provider` local state management, `fl_chart`, `file_picker`, and `table_calendar`.

## Features Included

### Shared Authentication (7 Screens)
- Splash Screen
- Welcome Screen (with Quick Demo Portal Access)
- Login Screen (with Student / Teacher role switch)
- Student Registration
- Teacher Registration
- Forgot Password
- Password Reset (demo code: `482910`)

### Student Portal (14 Screens · 5-Tab Bottom Navigation)
1. Student Dashboard (KPIs, `fl_chart` progress & score breakdown, upcoming deadlines, recent activities)
2. My Assignments (search, status filters, sorting)
3. Assignment Details
4. Assignment Upload (native `file_picker` + quick sample valid/invalid files)
5. File Validation (format, 10 MB size, and integrity validation)
6. OCR Processing (simulated text extraction progress & mock extracted text)
7. Submission Confirmation (receipt & mock reference number)
8. Evaluation Results (overall marks, rubric chart, score breakdowns)
9. Plagiarism Report (similarity ring, originality status, highlighted excerpts, matched sources)
10. Grammar and Content Analysis (grammar, readability, spelling & structure suggestions)
11. Feedback and Suggestions (strictly separates Teacher-Approved Feedback from Simulated AI Suggestions)
12. Deadlines and Calendar (`table_calendar` monthly view, completed vs. pending tasks)
13. Notifications (filterable, read tracking, deep links)
14. Student Profile and Settings (edit profile, change password, notification toggles, logout)

### Teacher Portal (15 Screens · 5-Tab Bottom Navigation)
1. Teacher Dashboard (KPIs, flagged alert banner, `fl_chart` submission stats, deadlines, recent activity)
2. Create / Edit Assignment (full form validation, deadline picker, format chips)
3. Manage Assignments (search, subject filters, edit, delete with confirmation)
4. Assignment Details (submission progress & student list)
5. Student Submissions (search, status filters, quick flagged access)
6. Submission Review (student details, file info, OCR preview, review actions)
7. AI Evaluation Report (simulated AI score, rubric charts)
8. Plagiarism Review (similarity breakdown, mark reviewed / flag academic integrity)
9. Grammar and Content Review
10. Flagged Submissions (high similarity & low-confidence OCR triage queue)
11. Grade Management (AI-suggested marks, slider/numeric override, approve & publish to Student Portal)
12. Feedback Management (write, edit, draft/publish, adopt simulated AI suggestions)
13. Student Performance and Reports (class metrics, assignment averages chart, student breakdown)
14. Notifications
15. Teacher Profile and Settings

## Demo Accounts
- **Student Portal**: `ayesha.khan@academix.edu` / `password123`
- **Teacher Portal**: `dr.usman@academix.edu` / `password123`

## Running Locally with Flutter SDK
If platform folders (`android/`, `ios/`) are not yet generated in your local clone:
```bash
flutter create --platforms=android,ios .
flutter pub get
flutter run
```
