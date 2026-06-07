Screen Flow Document Structure

Document Information
Member/Author:
Chu The Duc
Nguyen Xuan Truong
Language: English 
Version: 1
Project: Smart Stock App

Table of Contents 
Screen Flow Document Structure	1
Document Information	1
Table of Contents	1
A. Overview Flow Screen	4
Group 1 – App Start	5
Group 2 – QR / Barcode Scan Flow	5
Group 3 – Storage Location Flow	5
Group 4 – Inventory Check Flow	5
Group 5 – Inventory History	6
Group 6 – Data Synchronization	6
Group 7 – Notifications	6
Group 8 – Incident Report Flow	7
B. Screen Description	7
1. Login Screen	7
1.1 General Information	7
1.2 Wireframe	8
1.3 UI Components	8
1.4 User Flow	9
1.4.1 Main Flow	9
1.4.2 Navigation Flow	9
2. Home Screen	9
2.1 General Information	9
2.2 Wireframe	10
2.3 UI Components	10
2.4 User Flow	11
2.4.1 Main Flow	11
2.4.2 Navigation Flow	12
3. QR / Barcode Scanner Screen	12
3.1 General Information	12
3.2 Wireframe	13
3.3 UI Components	13
3.4 User Flow	14
3.4.1 Main Flow	14
3.4.2 Navigation Flow	14
4. Inventory Check List Screen	14
4.1 General Information	14
4.2 Wireframe	15
4.3 UI Components	15
4.4 User Flow	16
4.4.1 Main Flow	16
4.4.2 Navigation Flow	16
5. Create Inventory Check Screen	17
5.1 General Information	17
5.2 Wireframe	17
5.3 UI Components	18
5.4 User Flow	18
5.4.1 Main Flow	18
5.4.2 Navigation Flow	18
6. Select Product Screen	19
6.1 General Information	19
6.2 Wireframe	19
6.3 UI Components	20
6.4 User Flow	20
6.4.1 Main Flow	20
6.4.2 Navigation Flow	21
7. Inventory Check Detail Screen	21
7.1 General Information	21
7.2 Wireframe	22
7.3 UI Components	22
7.4 User Flow	24
7.4.1 Main Flow	24
7.4.2 Navigation Flow	24
8. Product List Screen	24
8.1 General Information	24
8.2 Wireframe	25
8.3 UI Components	25
8.4 User Flow	26
8.4.1 Main Flow	26
8.4.2 Navigation Flow	27
9. Product Detail Screen	27
9.1 General Information	27
9.2 Wireframe	28
9.3 UI Components	28
9.4 User Flow	29
9.4.1 Main Flow	29
9.4.2 Navigation Flow	30
10. Confirm & Sync Screen	30
10.1 General Information	30
10.2 Wireframe	31
10.3 UI Components	31
10.4 User Flow	32
10.4.1 Main Flow	32
10.4.2 Navigation Flow	32
11. Profile Screen	33
11.1 General Information	33
11.2 Wireframe	33
11.3 UI Components	34
11.4 User Flow	35
11.4.1 Main Flow	35
11.4.2 Navigation Flow	35
12. Notification Screen	35
12.1 General Information	35
12.2 Wireframe	36
12.3 UI Components	36
12.4 User Flow	37
12.4.1 Main Flow	37
12.4.2 Navigation Flow	37
13. Inventory History Screen	38
13.1 General Information	38
13.2 Wireframe	38
13.3 UI Components	39
13.4 User Flow	39
13.4.1 Main Flow	39
13.4.2 Navigation Flow	39
14. Warehouse Location Screen	40
14.1 General Information	40
14.2 Wireframe	40
14.3 UI Components	41
14.4 User Flow	41
14.4.1 Main Flow	41
14.4.2 Navigation Flow	42
15. Warehouse Map Screen	42
15.1 General Information	42
15.2 Wireframe	43
15.3 UI Components	43
15.4 User Flow	44
15.4.1 Main Flow	44
15.4.2 Navigation Flow	44
16. Incident Report Screen	45
16.1 General Information	45
16.2 Wireframe	45
16.3 UI Components	46
16.4 User Flow	46
16.4.1 Main Flow	46
16.4.2 Navigation Flow	47



A. Overview Flow Screen
 


Group 1 – App Start
Splash Screen
Displays the app logo for 1–2 seconds when the app opens. It initializes the connection and checks whether the login token is still valid. If valid, the user is redirected to Home without logging in again.
Login Screen
Allows users to log in with the same account used on the web system. After successful login, the token is saved on the device to maintain the session. Error messages are shown for incorrect credentials or network issues.
Home Screen
The main screen after login. It provides navigation to the main features and may show quick statistics such as unfinished inventory checks, pending sync data, or low-stock alerts.
Group 2 – QR / Barcode Scan Flow
Scan QR / Barcode
Opens the camera to scan product barcodes, product QR codes, batch QR codes, or storage location QR codes. This helps users quickly look up information without manual searching.
Product Detail from Scan
Displays detailed product information, including description, unit, available batches, recent stock-in/stock-out history, and inventory status.
Group 3 – Storage Location Flow
Storage Location List
Shows all warehouse locations such as shelves, cabinets, or damaged-goods areas. Each location includes its code, name, number of stored products, and notes.
Product Detail from Location
Displays product details from a selected storage location. Staff can view product information, start an inventory check, or report an issue from this screen.
Group 4 – Inventory Check Flow
Inventory Check List
Shows all inventory check sessions with statuses such as Draft, Submitted, Approved, and Rejected. Staff can create a new session or continue an unfinished one.
Inventory Check Detail
The main screen for the inventory process. It shows checked and unchecked products, system quantity, actual quantity, and differences. Staff actions update the results on this screen.
Sync Status after Submit
Shows the submission progress, including whether the inventory form, images, and notes have been synced. Statuses include Pending, Syncing, Synced, and Failed. Failed items can be retried.
Group 5 – Inventory History
Inventory History
Shows completed inventory check sessions sorted by date. It includes the form code, date, staff member, location, number of differences, and approval status.
Inventory History Detail
Displays the details of a completed inventory session, including product lines, system quantity, actual quantity, differences, photos, notes, approval result, and rejection reason if any. This screen is view-only.
Group 6 – Data Synchronization
Sync Status from Home
Provides an overview of all local data synchronization, including pending forms, unuploaded images, and failed data.
Sync Now
Allows staff to manually start synchronization immediately, especially after the network connection is restored.
Retry Failed Sync
Shows failed sync items and allows staff to retry each item or retry all. It also displays the failure reason.
Offline Pending Data
Shows all data stored locally but not yet sent to the server, such as inventory forms, photos, and notes.
Group 7 – Notifications
Notifications
Displays push notifications from the server, such as assigned inventory tasks, approval results, rejected forms, low-stock alerts, and sync errors.
Inventory Task Detail from Notification
Shows the assigned inventory task, including the required location, deadline, and manager’s notes. Staff can start the task directly from this screen.
Inventory Result Detail from Notification
Shows the manager’s approval result, including whether the form was approved or rejected, the rejection reason, and any required follow-up actions.
Group 8 – Incident Report Flow 
Create Incident Report
Allows staff to report warehouse issues such as damaged products, missing items, wrong storage locations, broken shelves, incorrect quantity, or barcode/QR code errors. Staff can enter a description, select the related product or location, attach photos, and submit the report. 


B. Screen Description
1. Login Screen
1.1 General Information
Field
Description
Screen Name
Login Screen
Screen ID
SCR_LOGIN_01
Module
Authentication
Purpose
Allow users to log into the system.
User/Actor
Guest User


1.2 Wireframe

1.3 UI Components
Section
Component
Data Type
Description
Body/Content
App Logo
Image
Display the app logo.
Body/Content
App Title
Label
Displays 'Smart Stock' and subtitle.
Body/Content
Employee ID / Email Input
Text Field
Enter employee code or email.
Body/Content
Password Label
Label
Displays 'Mật khẩu' (Password).
Body/Content
Forgot Password
Text Button
Navigate to the forgot password screen.
Body/Content
Password Input
Password Field
Enter your password.
Body/Content
Show/Hide Password
Icon Button
Hide/show password text.
Body/Content
Login Button
Button
Log in to the system.
Body/Content
Divider with 'hoặc'
Label
Separator text 'or'.
Body/Content
Login with Google Button
Button
Log in using a Google account.


1.4 User Flow
1.4.1 Main Flow
1. User opens the application.
2. The system displays the Login Screen.
3. User enters their employee ID or email and password.
4. User presses the Login Button.
5. The system verifies the account.
6. Login successful → proceeds to the Home Screen.
1.4.2 Navigation Flow
Action
Destination
Tap Login Button
Home Screen
Tap Forgot Password
Forgot Password Screen
Tap Login with Google
Google Auth Flow


2. Home Screen
2.1 General Information
Screen Name
Home Screen
Screen ID
SCR_HOME_01
Module
Dashboard
Purpose
Provide a quick overview of inventory check stats, recent activities, and shortcuts to key features.
User/Actor
Warehouse Staff


2.2 Wireframe

2.3 UI Components
Section
Component
Data Type
Description
Header
App Logo / Title
Label
Displays 'Smart Stock' branding and app icon.
Header
Notification Bell
Icon Button
Navigates to the Notification Screen.
Body
User Greeting Card
Display Card
Shows logged-in user's name and current working shift/warehouse.
Body
Avatar Image
Image
Displays the user's profile picture.
Body
Today's Inventory Count Card
Display Card
Large red card showing total inventory check orders today and daily change count.
Body
Scanned Items Stat Card
Display Card
Shows total items scanned (e.g., 1,240 items) with trend icon.
Body
Discrepancy (Lệch tồn) Stat Card
Display Card
Pink card showing number of stock discrepancies detected (e.g., 18).
Body
Quick Access - Reports
Icon Button
Navigates to the Reports Screen.
Body
Quick Access - Tasks
Icon Button
Navigates to the Tasks Screen.
Body
Quick Access - Inventory Check
Icon Button
Navigates to the Inventory Check List Screen.
Body
Quick Access - Warehouse Location
Icon Button
Navigates to the Warehouse Location Screen.
Body
Recent Activities List
List
Displays the latest warehouse activities with status badges.
Body
View All Button
Text Button
Navigates to the full activity history screen.
Bottom Nav
Home Tab (Active)
Nav Button
Active tab — current screen.
Bottom Nav
Kiểm kê Tab
Nav Button
Navigates to Inventory Check List Screen.
Bottom Nav
Scan Tab
Nav Button
Opens QR Scanner Screen.
Bottom Nav
Lịch sử Tab
Nav Button
Navigates to Inventory History Screen.
Bottom Nav
Cá nhân Tab
Nav Button
Navigates to Profile Screen.


2.4 User Flow
2.4.1 Main Flow
1. User logs in successfully.
2. System navigates to the Home Screen.
3. System loads and displays inventory check statistics (today's orders, scanned items, discrepancies).
4. System loads and displays recent activity list.
5. User can tap any Quick Access shortcut or bottom navigation tab to proceed.

2.4.2 Navigation Flow
Action
Destination
Tap Reports shortcut
Reports Screen
Tap Tasks shortcut
Tasks Screen
Tap Inventory Check shortcut / Bottom Nav
Inventory Check List Screen
Tap Warehouse Location shortcut
Warehouse Location Screen
Tap Scan / Bottom Nav
QR Scanner Screen
Tap Notification Bell
Notification Screen
Tap Lịch sử / Bottom Nav
Inventory History Screen
Tap Cá nhân / Bottom Nav
Profile Screen
Tap View All (Recent Activities)
Activity History Screen


3. QR / Barcode Scanner Screen
3.1 General Information
Screen Name
QR / Barcode Scanner Screen
Screen ID
SCR_SCAN_01
Module
Scanning
Purpose
Allow users to scan QR codes or barcodes to quickly identify products or inventory items.
User/Actor
Warehouse Staff


3.2 Wireframe

3.3 UI Components
Section
Component
Data Type
Description
Header
Close Button (X)
Icon Button
Closes the scanner and returns to the previous screen.
Header
Screen Title
Label
Displays 'Quét mã' (Scan Code).
Body
Camera Viewfinder
Camera View
Live camera preview for scanning QR/barcode.
Body
Scan Frame Overlay
Overlay
Red-corner frame guides the user to align the code for scanning.
Body
Instruction Text
Label
Displays hint text: 'Căn chỉnh mã vào khung để quét'.
Body
Flash Button
Icon Button
Toggles the device flashlight on/off.
Body
Gallery / Library Button
Icon Button
Opens the device photo library to select an image containing a code.
Footer
Manual Input Button
Button
Opens a manual code entry dialog for typing a product code.


3.4 User Flow
3.4.1 Main Flow
1. User taps the Scan tab or QR Scan shortcut from the Home Screen.
2. System requests camera permission (if not already granted).
3. System opens the Scanner Screen with a live camera view.
4. User aligns the QR code or barcode within the scan frame.
5. System detects and reads the code automatically.
6. System navigates to the relevant Product Detail or Inventory Check Detail Screen.
3.4.2 Navigation Flow
Action
Destination
Tap Close (X)
Previous Screen
Successful scan
Product Detail Screen or Inventory Check Detail Screen
Tap Manual Input
Manual Code Entry Dialog
Tap Gallery/Library
Device Photo Library


4. Inventory Check List Screen
4.1 General Information
Screen Name
Inventory Check List Screen
Screen ID
SCR_INV_LIST_01
Module
Inventory Check
Purpose
Display all inventory check sessions with their statuses; allow users to search, filter, and create new sessions.
User/Actor
Warehouse Staff / Warehouse Manager


4.2 Wireframe

4.3 UI Components
Section
Component
Data Type
Description
Header
App Logo / Title
Label
Displays Smart Stock branding.
Header
Notification Bell
Icon Button
Navigates to the Notification Screen.
Body
Search Bar
Text Input
Searches inventory sessions by session code.
Body
Section Title
Label
Displays 'Danh sách kiểm kê' heading and subtitle.
Body
Filter Tabs
Tab Bar
Filter chips: Tất cả (All), Đang thực hiện (In Progress), Chờ xử lý (Pending).
Body
Session Card - In Progress
List Item Card
Shows session ID, date, progress bar and percentage (e.g. INV-2023-001 — 65%).
Body
Session Card - Pending
List Item Card
Shows session ID, date, status 'Chờ xử lý', and a 'BẮT ĐẦU' (START) action button.
Body
Session Card - Completed
List Item Card
Shows session ID, date, status 'Hoàn thành', and 'XEM BÁO CÁO' (VIEW REPORT) link.
Footer FAB
Create New (+) Button
Floating Action Button
Opens the Create Inventory Check Screen.
Bottom Nav
Trang chủ Tab
Nav Button
Navigates to Home Screen.
Bottom Nav
Kiểm kê Tab (Active)
Nav Button
Active tab — current screen.
Bottom Nav
Scan Tab
Nav Button
Opens QR Scanner Screen.
Bottom Nav
Lịch sử Tab
Nav Button
Navigates to Inventory History Screen.
Bottom Nav
Cá nhân Tab
Nav Button
Navigates to Profile Screen.


4.4 User Flow
4.4.1 Main Flow
1. User taps the Kiểm kê tab from the Bottom Navigation.
2. System loads and displays the list of all inventory check sessions.
3. User can filter sessions using the tab chips (All / In Progress / Pending).
4. User taps a session card to view its detail.
5. User taps the (+) FAB button to create a new session.
4.4.2 Navigation Flow
Action
Destination
Tap session card
Inventory Check Detail Screen
Tap 'BẮT ĐẦU' on a pending session
Inventory Check Detail Screen
Tap 'XEM BÁO CÁO' on a completed session
Inventory Report Screen
Tap (+) FAB
Create Inventory Check Screen
Tap Notification Bell
Notification Screen


5. Create Inventory Check Screen
5.1 General Information
Screen Name
Create Inventory Check Screen
Screen ID
SCR_INV_CREATE_01
Module
Inventory Check
Purpose
Allow users to fill in details and initiate a new inventory check session for a specific warehouse location.
User/Actor
Warehouse Staff / Warehouse Manager


5.2 Wireframe

5.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the Inventory Check List Screen.
Header
Screen Title
Label
Displays 'Tạo phiếu kiểm kê' (Create Inventory Check Sheet).
Header
App Logo Icon
Image
Smart Stock branding icon.
Body
Instruction Text
Label
Short description guiding the user to fill in details.
Body
Warehouse Name Dropdown
Dropdown Select
Select the warehouse to be checked.
Body
Location Input
Text Input
Enter the specific shelf or zone location (e.g., Kệ A-12, Khu vực 1).
Body
Check Date Picker
Date Picker
Select the date of the inventory check (default: today).
Body
Assigned Staff Field
Read-Only Text
Auto-populated with the currently logged-in user's name (e.g., Nguyễn Văn A).
Body
Notes / Reason Input
Multi-line Text Input
Optional notes or reason for conducting this inventory check.
Footer
Start Inventory Check Button
Primary Button
Validates form and initiates the inventory check session.


5.4 User Flow
5.4.1 Main Flow
1. User taps the (+) FAB from the Inventory Check List Screen.
2. System displays the Create Inventory Check Screen.
3. User selects a warehouse from the dropdown.
4. User enters the location, confirms the date, and optionally adds notes.
5. User taps 'Bắt đầu kiểm kê' (Start Inventory Check).
6. System validates all required fields.
7. System creates the session and navigates to the Inventory Check Detail Screen.
5.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Inventory Check List Screen
Tap 'Bắt đầu kiểm kê' (valid form)
Inventory Check Detail Screen


6. Select Product Screen
6.1 General Information
Screen Name
Select Product Screen
Screen ID
SCR_SEL_PROD_01
Module
Inventory Check
Purpose
Allow users to browse, search, and select products to include in an inventory check session, with advanced filtering options.
User/Actor
Warehouse Staff


6.2 Wireframe

6.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the previous screen.
Header
Screen Title
Label
Displays 'Chọn Sản phẩm' (Select Product).
Header
Search Icon Button
Icon Button
Activates the search bar.
Body
Search Bar
Text Input
Search by product name or SKU.
Body
Advanced Filter Button
Icon Button
Opens the Advanced Filter modal (see below).
Body
Location Filter Chips
Tab Chips
Filter by shelf/zone: Tất cả, Kệ A1, Kệ B2, S/N Tracking.
Body
Product List Item
List Item Card
Displays product name, SKU, shelf tag, tracking type, and actual quantity input.
Body
Product Selection Checkbox
Checkbox
Marks or unmarks a product for selection.
Body
Actual Quantity Input
Number Input
User enters the physically counted quantity for each product (labeled 'Thực tế').
Modal — Advanced Filter
Close Button (X)
Icon Button
Closes the filter modal without applying changes.
Modal — Advanced Filter
Location Filter
Multi-select Chips
Filter by location: Kệ A1, Kệ B2, Kệ C3.
Modal — Advanced Filter
Tracking Method Filter
Multi-select Chips
Filter by: S/N Tracking, Batch Tracking, No Tracking.
Modal — Advanced Filter
Stock Status Filter
Multi-select Chips
Filter by: Còn hàng (In Stock), Hết hàng (Out of Stock).
Modal — Advanced Filter
Reset Button
Secondary Button
Resets all filter selections.
Modal — Advanced Filter
Apply Button
Primary Button
Applies selected filters and refreshes the product list.


6.4 User Flow
6.4.1 Main Flow
1. System displays the product list for the selected warehouse.
2. User searches or uses filter chips to find products.
3. User enters the actual counted quantity for each product.
4. User checks the checkbox to select products.
5. System updates selected count in header.
6. User taps to confirm selection.
6.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Previous Screen (Inventory Check Detail)
Tap Advanced Filter icon
Advanced Filter Modal (inline)
Tap Apply in modal
Filtered Product List
Tap Confirm Selection
Inventory Check Detail Screen


7. Inventory Check Detail Screen
7.1 General Information
Screen Name
Inventory Check Detail Screen
Screen ID
SCR_INV_DETAIL_01
Module
Inventory Check
Purpose
Display all products in an inventory check session, allow users to enter actual counted quantities, and complete or save it.
User/Actor
Warehouse Staff


7.2 Wireframe

7.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the Inventory Check List Screen.
Header
Screen Title
Label
Displays 'Chi tiết Kiểm kê' in red.
Header
More Options Icon
Icon Button
Opens additional options menu.
Body
Session Info Row - Voucher Code
Label
Displays the session voucher ID (e.g., INV-2023-001) in red.
Body
Session Info Row - Warehouse
Label
Displays the warehouse name (e.g., Kho Chính - Tầng 1).
Body
Session Info Row - Created Date
Label
Displays the date the session was created.
Body
Search Bar
Text Input
Searches products within this session by name or SKU.
Body
Filter Button
Icon Button
Opens the Filter modal for this session (see below).
Body
Product Item Card - Matched
List Item Card
Green checkmark; shows product name, SKU, location, lot, serial, channel, system qty, and actual qty input.
Body
Product Item Card - Discrepancy
List Item Card
Warning icon; shown when actual quantity differs from system quantity.
Body
Product Item Card - Pending
List Item Card
Question mark icon; dashes shown in actual quantity field for items not yet counted.
Body
Actual Quantity Input
Number Input
User inputs the physically counted quantity for each item.
Body
Scan QR Icon per Item
Icon Button
Opens QR scanner to scan a serial/lot code for that specific product.
Footer
Quick Scan QR Button
Primary Button
Opens QR Scanner to quickly find and update a product.
Footer
Save Draft Button (Lưu tạm)
Secondary Button
Saves current progress without completing the session.
Footer
Complete Button (Hoàn thành)
Primary Button
Marks the session as completed and submits the data.
Modal — Filter
Status Filter
Multi-select Chips
Filter by: Tất cả, Khớp, Lệch, Chưa kiểm.
Modal — Filter
Tracking Type Filter
Multi-select Chips
Filter by: Tất cả, Batch, Serial, Số lượng.
Modal — Filter
Zone Filter
Multi-select Chips
Filter by warehouse zones: Tất cả, Khu A, Khu B, Khu C, Khu D.
Modal — Filter
Reset Button
Secondary Button
Resets all filter criteria.
Modal — Filter
Apply Button
Primary Button
Applies filters and refreshes the product list.


7.4 User Flow
7.4.1 Main Flow
1. User taps a session card from the Inventory Check List Screen.
2. System loads and displays session metadata and all product items.
3. User enters the actual counted quantity for each product item.
4. User can use Quick Scan QR to scan serial/lot codes.
5. User taps 'Lưu tạm' to save progress, or 'Hoàn thành' to finalize the session.
6. On 'Hoàn thành', system validates all items and submits the session.
7.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Inventory Check List Screen
Tap Quick Scan QR
QR Scanner Screen
Tap Filter icon
Filter Modal (inline)
Tap Apply in modal
Filtered Product List
Tap Hoàn thành (all items filled)
Inventory Check Confirmation / Sync Screen
Tap Lưu tạm
Inventory Check List Screen (session saved as draft)


8. Product List Screen
8.1 General Information
Screen Name
Product List Screen
Screen ID
SCR_PROD_LIST_01
Module
Inventory / Product Management
Purpose
Display all products in the warehouse with search, category filter, and sorting/filter options.
User/Actor
Warehouse Staff / Warehouse Manager


8.2 Wireframe

8.3 UI Components
Section
Component
Data Type
Description
Header
App Logo / Title
Label
Displays Smart Stock branding.
Header
Notification Bell
Icon Button
Navigates to the Notification Screen.
Body
Search Bar
Text Input
Search products by name or SKU.
Body
Filter/Sort Button
Icon Button
Opens the Filter & Sort modal (see below).
Body
Category Filter Chips
Tab Chips
Filter by category: Tất cả, Điện tử, Linh kiện, Gia dụng, etc.
Body
Product Card
List Item Card
Shows product thumbnail image, name, SKU, stock status badge (Lô hàng), quantity, shelf location tag, and 3-dot menu.
Body
Low Stock Warning Icon
Icon/Label
Red warning triangle shown next to quantity when stock is below threshold.
Bottom Nav
Trang chủ Tab
Nav Button
Navigates to Home Screen.
Bottom Nav
Kiểm kê Tab (Active)
Nav Button
Active tab — current screen.
Bottom Nav
Scan Tab
Nav Button
Opens QR Scanner Screen.
Bottom Nav
Lịch sử Tab
Nav Button
Navigates to Inventory History Screen.
Bottom Nav
Cá nhân Tab
Nav Button
Navigates to Profile Screen.
Modal — Filter & Sort
Sort By
Single-select Chips
Sort by: Tên (Name), Số lượng (Quantity), Vị trí (Location).
Modal — Filter & Sort
Tracking Method
Single-select Chips
Filter by: Số lượng, Lô hàng, Serial.
Modal — Filter & Sort
Warehouse Status
Single-select Chips
Filter by: Còn hàng, Sắp hết, Hết hàng.
Modal — Filter & Sort
Reset Button
Secondary Button
Resets all filter and sort selections.
Modal — Filter & Sort
Apply Button
Primary Button
Applies the selected filters/sort and refreshes the product list.


8.4 User Flow
8.4.1 Main Flow
1. User navigates to the Product List via the bottom navigation.
2. System loads and displays all products with default sorting.
3. User can search by name/SKU or filter by category chips.
4. User taps the filter icon to open the Filter & Sort modal.
5. User selects sort/filter criteria and taps Apply.
6. User taps a product card to view its detail.
8.4.2 Navigation Flow
Action
Destination
Tap product card
Product Detail Screen
Tap 3-dot menu on a card
Quick Action Menu (Edit / Export / Delete)
Tap Filter icon
Filter & Sort Modal (inline)
Tap Apply in modal
Filtered / Sorted Product List


9. Product Detail Screen
9.1 General Information
Screen Name
Product Detail Screen
Screen ID
SCR_PROD_DETAIL_01
Module
Inventory / Product Management
Purpose
Display comprehensive information about a specific product, including stock quantity, location, tracking method, technical specs, and recent activity.
User/Actor
Warehouse Staff / Warehouse Manager


9.2 Wireframe

9.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the Product List Screen.
Header
Screen Title
Label
Displays 'Chi tiết Sản phẩm' (Product Detail).
Header
App Logo Icon
Image
Smart Stock branding icon.
Body
Product Image
Image
Large banner image of the product.
Body
SKU Badge
Label Badge
Displays the product's SKU code (e.g., CPU-INT-13700).
Body
Category Badge
Label Badge
Displays the product category (e.g., Vị xử lý (CPU)).
Body
Product Name
Heading Label
Large display of the product name (e.g., Intel Core i7-13700K).
Body
Stock Quantity Card
Info Card
Shows current stock quantity with unit and label 'SỐ LƯỢNG' (e.g., 142 cái).
Body
Location Card
Info Card
Shows current warehouse shelf location with label 'VỊ TRÍ' (e.g., Kệ A-12).
Body
Status Card
Info Card
Shows stock status (e.g., Sẵn sàng xuất kho) and condition badge (Bình thường).
Body
Tracking Method Section
Info Section
Shows management type (e.g., Serial Number S/N) with description note.
Body
Technical Specifications Section
Info Table
Displays product specs in a key-value list (e.g., Socket, Số nhân/luồng, Xung nhịp tối đa).
Body
Recent Activity Section
Activity List
Shows the latest warehouse activities for this product (import, inventory check, etc.).
Footer
Edit / Adjust Button (Chỉnh sửa)
Secondary Button
Opens the Edit Product Screen.
Footer
Quick Inventory Check Button
Primary Button
Opens a quick inventory check for this specific product.


9.4 User Flow
9.4.1 Main Flow
1. User taps a product card from the Product List Screen.
2. System loads and displays all product details.
3. User reviews stock quantity, location, tracking method, and specs.
4. User taps 'Chỉnh sửa' to modify product information.
5. User taps 'Kiểm kê nhanh' to initiate a check for this product.
9.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Product List Screen
Tap Chỉnh sửa (footer)
Edit Product Screen
Tap Kiểm kê nhanh
Inventory Check Detail Screen (for this product)


10. Confirm & Sync Screen
10.1 General Information
Screen Name
Confirm & Sync Screen
Screen ID
SCR_SYNC_01
Module
Sync / Offline Management
Purpose
Allow users to view offline-pending inventory sessions and manually trigger synchronization when connectivity is restored.
User/Actor
Warehouse Staff


10.2 Wireframe

10.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the previous screen.
Header
Screen Title
Label
Displays 'Xác nhận & Đồng bộ' (Confirm & Sync).
Header
Notification Bell
Icon Button
Navigates to the Notification Screen.
Body
Offline Status Card
Status Card
Displays a cloud-off icon, 'Ngoại tuyến' (Offline) label, and 'Mất kết nối mạng' message.
Body
Pending Data Card
Info Card
Shows number of inventory sessions waiting to be synced (e.g., 8 phiên kiểm kê).
Body
Last Sync Card
Info Card
Displays timestamp of last successful sync (e.g., 14:30, Hôm nay, 24/10/2023).
Body
Pending Sessions Section Title
Label
Section heading 'Chi tiết phiên chờ' (Pending Session Details).
Body
Pending Session Item - Pending
List Item Card
Shows session ID, 'Pending' status badge, zone, product count, last updated time, and 'XEM CHI TIẾT' button.
Body
Pending Session Item - Failed
List Item Card
Shows session ID, 'Failed' status badge (red), zone, error message, and 'XEM CHI TIẾT' button.
Footer
Sync Now Button (Đồng bộ ngay)
Primary Button
Triggers manual synchronization (disabled/greyed out when offline).


10.4 User Flow
10.4.1 Main Flow
1. User opens the Confirm & Sync Screen (e.g., after returning from offline work).
2. System detects network status and displays Offline/Online accordingly.
3. System lists all pending sessions awaiting sync.
4. User reviews each pending or failed session by tapping 'XEM CHI TIẾT'.
5. When connectivity is restored, user taps 'Đồng bộ ngay' to upload all pending data.
6. System syncs data and updates session statuses.
10.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Previous Screen
Tap XEM CHI TIẾT on a session
Inventory Check Detail Screen (read-only)
Tap Đồng bộ ngay (online)
Sync Progress / Result Screen


11. Profile Screen
11.1 General Information
Screen Name
Profile Screen
Screen ID
SCR_PROFILE_01
Module
User Settings
Purpose
Allow users to view their profile information and manage account settings, app preferences, and access support resources.
User/Actor
Warehouse Staff / Warehouse Manager


11.2 Wireframe

11.3 UI Components
Section
Component
Data Type
Description
Header
App Logo / Title
Label
Displays 'Smart Stock' branding.
Header
Notification Bell
Icon Button
Navigates to the Notification Screen.
Body
Avatar Image
Circular Image
Displays the user's profile photo with an edit (pencil) overlay button.
Body
User Name
Display Label
Shows the full name of the logged-in user (e.g., Nguyễn Văn An).
Body
Employee ID
Display Label
Shows the employee code (e.g., NV-8821) highlighted in red.
Body
Assigned Warehouse Badge
Badge Label
Shows the warehouse the user is assigned to (e.g., Kho Chính - Tầng 1).
Section — Tài khoản
Edit Personal Info
List Item/Nav Row
Navigates to the Edit Personal Information Screen.
Section — Tài khoản
Change Password
List Item/Nav Row
Navigates to the Change Password Screen.
Section — Cài đặt ứng dụng
Language
List Item/Nav Row
Shows current language (e.g., Tiếng Việt) and navigates to Language Selection.
Section — Cài đặt ứng dụng
Notifications Toggle
Toggle Switch
Enables or disables push notifications. (Default: ON)
Section — Cài đặt ứng dụng
Dark Mode Toggle
Toggle Switch
Enables or disables dark mode. (Default: OFF)
Section — Hỗ trợ & Bảo mật
User Guide
List Item/Nav Row
Opens the in-app user guide / help documentation.
Section — Hỗ trợ & Bảo mật
Privacy Policy
List Item/Nav Row
Opens the privacy policy page.
Section — Hỗ trợ & Bảo mật
Report a Bug
List Item/Nav Row
Opens the bug report / feedback form.
Footer
Logout Button (Đăng xuất)
Primary Button
Logs the user out and returns to the Login Screen.
Bottom Nav
Trang chủ Tab
Nav Button
Navigates to Home Screen.
Bottom Nav
Kiểm kê Tab
Nav Button
Navigates to Inventory Check List Screen.
Bottom Nav
Scan Tab
Nav Button
Opens QR Scanner Screen.
Bottom Nav
Lịch sử Tab
Nav Button
Navigates to Inventory History Screen.
Bottom Nav
Cá nhân Tab (Active)
Nav Button
Active tab — current screen.


11.4 User Flow
11.4.1 Main Flow
1. User taps the Cá nhân tab from the Bottom Navigation.
2. System loads and displays the user's profile information and settings.
3. User can update personal info, change password, or adjust app preferences.
4. User can access support resources (User Guide, Privacy Policy, Bug Report).
5. User taps 'Đăng xuất' to sign out of the application.
11.4.2 Navigation Flow
Action
Destination
Tap Edit Personal Info
Edit Personal Info Screen
Tap Change Password
Change Password Screen
Tap Language
Language Selection Screen
Tap User Guide
User Guide Screen
Tap Privacy Policy
Privacy Policy Screen
Tap Report a Bug
Bug Report / Feedback Screen
Tap Đăng xuất
Login Screen


12. Notification Screen
12.1 General Information
Screen Name
Notification Screen
Screen ID
SCR_NOTIF_01
Module
Notifications
Purpose
Display all system notifications including stock alerts, task assignments, system messages, and warehouse updates.
User/Actor
Warehouse Staff / Warehouse Manager


12.2 Wireframe

12.3 UI Components
Section
Component
Data Type
Description
Header
App Logo / Title
Label
Displays 'Smart Stock'.
Header
Notification Bell (with dot)
Icon Button
Indicates unread notifications; currently active screen.
Body
Screen Heading
Display Label
Large heading 'Thông báo' with subtitle.
Body
All Tab (Active)
Tab Chip
Shows all notifications.
Body
Unread Tab
Tab Chip
Filters to show only unread notifications.
Body
Filter Icon
Icon Button
Opens notification type filter options.
Body
Mark All as Read Button
Text Button
Marks all notifications as read.
Body
Notification Item — Stock Alert
List Item Card
Alert icon, title 'Cảnh báo sắp hết…', type badge (KHO HÀNG), time, description, 'XEM CHI TIẾT' link.
Body
Notification Item — Task
List Item Card
Task icon, title 'Nhiệm vụ nhập hàng…', type badge (NHIỆM VỤ), time, description, 'XEM NHIỆM VỤ' link.
Body
Notification Item — System
List Item Card
System icon, title 'Bảo trì hệ thống', type badge (HỆ THỐNG), time, and description.
Body
Notification Item — Received Lot
List Item Card
Warehouse icon, title 'Đã nhận lô hàng', type badge (KHO HÀNG), time, and description.
Bottom Nav
Trang chủ Tab (Active)
Nav Button
Active tab — navigates to Home Screen.
Bottom Nav
Kiểm kê Tab
Nav Button
Navigates to Inventory Check List Screen.
Bottom Nav
Scan Tab
Nav Button
Opens QR Scanner Screen.
Bottom Nav
Lịch sử Tab
Nav Button
Navigates to Inventory History Screen.
Bottom Nav
Cá nhân Tab
Nav Button
Navigates to Profile Screen.


12.4 User Flow
12.4.1 Main Flow
1. User taps the Notification Bell icon from the Header.
2. System loads and displays all notifications in reverse chronological order.
3. User can switch between 'Tất cả' and 'Chưa đọc' tabs.
4. User taps 'XEM CHI TIẾT' or 'XEM NHIỆM VỤ' to navigate to the relevant screen.
5. User taps 'Đánh dấu đã đọc' to clear unread indicators.
12.4.2 Navigation Flow
Action
Destination
Tap 'XEM CHI TIẾT' on stock alert
Product Detail Screen
Tap 'XEM NHIỆM VỤ' on task notif.
Task Detail Screen
Tap a system/lot notification
Relevant Detail Screen
Tap 'Đánh dấu đã đọc'
All notifications marked read (same screen)


13. Inventory History Screen
13.1 General Information
Screen Name
Inventory History Screen
Screen ID
SCR_INV_HIST_01
Module
Reports / History
Purpose
Display historical records of past inventory check sessions with accuracy rates and discrepancy counts.
User/Actor
Warehouse Manager / Warehouse Staff


13.2 Wireframe

13.3 UI Components
Section
Component
Data Type
Description
Header
App Logo / Title
Label
Displays 'Smart Stock'.
Header
Notification Bell
Icon Button
Navigates to the Notification Screen.
Body
Section Heading
Display Label
Large heading 'Lịch sử kiểm kê' with subtitle.
Body
Search Bar
Text Input
Search sessions by ID or assigned staff name.
Body
Filter Button
Icon Button
Opens the filter panel for sorting/filtering history records.
Body
Area Filter Chips
Tab Chips
Filter by warehouse area: Tất Cả, Khu A (Thô), Khu B (Thành Phẩm), etc.
Body
History Record Card
List Item Card
Shows session ID (e.g., #INV-2310-04), date, assigned staff name, area badge, accuracy percentage, discrepancy count.
Bottom Nav
Trang chủ Tab
Nav Button
Navigates to Home Screen.
Bottom Nav
Kiểm kê Tab
Nav Button
Navigates to Inventory Check List Screen.
Bottom Nav
Scan Tab
Nav Button
Opens QR Scanner Screen.
Bottom Nav
Lịch sử Tab (Active)
Nav Button
Active tab — current screen.
Bottom Nav
Cá nhân Tab
Nav Button
Navigates to Profile Screen.


13.4 User Flow
13.4.1 Main Flow
1. User navigates to the Inventory History Screen via the Lịch sử tab.
2. System loads and displays past inventory check sessions.
3. User can search by session ID or staff name.
4. User can filter by warehouse area using the filter chips.
5. User taps a history card to view detailed session results.
13.4.2 Navigation Flow
Action
Destination
Tap a history record card
Inventory Check Detail Screen (read-only)
Tap Filter button
Filter Panel / Modal
Tap Notification Bell
Notification Screen


14. Warehouse Location Screen
14.1 General Information
Screen Name
Warehouse Location Screen
Screen ID
SCR_WH_LOC_01
Module
Warehouse Management
Purpose
Display the hierarchical structure of the warehouse (zones, rows, bins) with capacity indicators, and provide navigation to specific storage areas.
User/Actor
Warehouse Staff / Warehouse Manager


14.2 Wireframe

14.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the previous screen.
Header
Screen Title
Label
Displays 'Vị trí kho' (Warehouse Location).
Header
App Logo Icon
Image
Smart Stock branding icon.
Body
Search Bar
Text Input
Search by SKU, zone, or area name.
Body
QR Scan Icon (in Search)
Icon Button
Opens QR Scanner to scan a location code directly.
Body
Advanced Filter Button
Icon Button
Opens filter options for the location list.
Body
Area Filter Chips
Tab Chips
Filter by area type: Tất cả khu vực, Nhu cầu cao, Kho lạnh, Hàng đặc biệt, etc.
Body
Breadcrumb Navigation
Breadcrumb
Shows current hierarchy path (e.g., Kho Alpha > Tầng 1 > Khu vực A).
Body
Row/Shelf Card
List Item Card
Displays row name (e.g., Dãy A-10), category, capacity percentage badge, and sub-bin links.
Body
Capacity Warning Badge
Status Badge
Red/warning badge shown when capacity exceeds 90% (e.g., Dãy A-11: ĐẦY 98% with warning icon).
Body
Sub-bin Links
Navigation Links
Grid of bin range links within each row (e.g., Thùng 01-05, Thùng 06-10).
Footer
Scan Location Button
Primary Button
Opens QR scanner to scan a location code.
Footer
View Map Button
Secondary Button
Opens the Warehouse Map Screen.


14.4 User Flow
14.4.1 Main Flow
1. User navigates to the Warehouse Location Screen from the Home Screen quick access.
2. System loads and displays the warehouse zone/row/bin structure.
3. User browses by tapping area filter chips or scrolling the list.
4. User can tap a sub-bin link to drill down into a specific storage bin.
5. User taps 'Xem bản đồ' to open the Warehouse Map for a visual overview.
14.4.2 Navigation Flow
Action
Destination
Tap a sub-bin link
Bin Detail Screen
Tap Xem bản đồ
Warehouse Map Screen
Tap QR Scan icon in search
QR Scanner Screen
Tap Quét vị trí (footer)
QR Scanner Screen


15. Warehouse Map Screen
15.1 General Information
Screen Name
Warehouse Map Screen
Screen ID
SCR_WH_MAP_01
Module
Warehouse Management
Purpose
Display an interactive visual map of warehouse zones/bins with color-coded capacity status, and allow users to locate themselves in the warehouse.
User/Actor
Warehouse Staff / Warehouse Manager


15.2 Wireframe

15.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the Warehouse Location Screen.
Header
Screen Title
Label
Displays 'Bản đồ Kho' (Warehouse Map).
Body
Legend Card
Info Card
Color-coding legend: Red = Full/Warning (>90%), Teal = Normal (<90%), Light Grey = Empty.
Body
Zone Column Headers
Label Row
Displays column headers for each zone (e.g., Khu A, Khu B, Khu C).
Body
Bin Tile — Full/Warning (Red)
Tappable Tile
Red tile indicating bin capacity > 90%. Tap to view bin detail.
Body
Bin Tile — Normal (Teal)
Tappable Tile
Teal tile indicating bin capacity < 90%. Tap to view bin detail.
Body
Bin Tile — Empty (Grey)
Tappable Tile
Grey tile indicating an empty bin. Tap to view bin detail.
Body
Current Location Marker
Overlay Icon
Person icon overlay showing the user's current position on the map.
Body
Zoom In Button (+)
Icon Button
Zooms in on the map.
Body
Zoom Out Button (−)
Icon Button
Zooms out on the map.
Body
Re-center / Locate Button
Icon Button
Re-centers the map on the user's current location.
Footer
Scan Location Button
Primary Button
Opens QR scanner to scan a location code.
Footer
Detail List Button
Secondary Button
Opens the Warehouse Location list view.


15.4 User Flow
15.4.1 Main Flow
1. User taps 'Xem bản đồ' from the Warehouse Location Screen.
2. System loads and renders the warehouse map with color-coded bin tiles.
3. User views the legend to understand capacity color codes.
4. User taps a bin tile to view that bin's detail.
5. User uses Zoom In/Out and Re-center controls to navigate the map.
15.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Warehouse Location Screen
Tap a bin tile
Bin Detail Screen
Tap Quét vị trí (footer)
QR Scanner Screen
Tap Danh sách chi tiết
Warehouse Location Screen
Tap Re-center button
Map re-centers on current location (same screen)


16. Incident Report Screen
16.1 General Information
Screen Name
Incident Report Screen
Screen ID
SCR_INCIDENT_01
Module
Warehouse Management / Reporting
Purpose
Allow users to report incidents or issues with products in the warehouse, including attaching photos and descriptions.
User/Actor
Warehouse Staff / Warehouse Manager


16.2 Wireframe

16.3 UI Components
Section
Component
Data Type
Description
Header
Back Arrow
Icon Button
Returns to the previous screen.
Header
Screen Title
Label
Displays 'Báo cáo Sự cố' (Incident Report) in red.
Header
App Logo Icon
Image
Smart Stock branding icon.
Body
Product / SKU Field
Text Input + QR Button
Search or scan to select the product/SKU involved in the incident. Required field.
Body
Current Location Field
Read-Only Text
Auto-populated with the user's current warehouse location (e.g., Khu vực A • Kệ 04 • Tầng 2).
Body
Incident Type Dropdown
Dropdown Select
Select the type of incident (required field).
Body
Affected Quantity Control
Number Stepper
Adjust the number of affected items using minus/plus buttons (default: 1).
Body
Attach Photos Section
Image Upload
Capture or select up to 4 images as evidence (1 photo slot + 3 empty slots shown).
Body
Detailed Notes Input
Multi-line Text Input
Describe the incident in detail to support the resolution process.
Footer
Submit Report Button
Primary Button
Submits the incident report.


16.4 User Flow
16.4.1 Main Flow
1. User navigates to the Incident Report Screen (e.g., from a product detail or task context).
2. System auto-fills the current warehouse location.
3. User searches or scans to select the affected product/SKU.
4. User selects the incident type from the dropdown.
5. User adjusts the affected quantity using the stepper.
6. User optionally attaches up to 4 photos.
7. User enters detailed notes describing the incident.
8. User taps 'Gửi báo cáo' to submit the report.
9. System validates required fields (Product/SKU and Incident Type) and submits.
16.4.2 Navigation Flow
Action
Destination
Tap Back Arrow
Previous Screen
Tap QR icon in Product/SKU field
QR Scanner Screen
Tap Gửi báo cáo (valid form)
Report Confirmation / Success Screen


