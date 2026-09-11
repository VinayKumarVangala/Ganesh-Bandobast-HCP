# Figma Design Instructions — SVAMS (Seized Vehicle Auction Management System)
## Telangana Police | Working Prototype Blueprint

**File Name:** `SVAMS_Prototype_v1.0`  
**Target:** High-fidelity clickable prototype (desktop-first, responsive tablet/mobile)  
**Tool:** Figma (Auto Layout + Variables + Components + Prototype)

---

## 1. Figma File Structure

Create these **Pages** in exact order:

```
📄 00_Cover
📄 01_Design_Tokens
📄 02_Components
📄 03_Patterns
📄 04_Flows_Overview
📄 05_Auth
📄 06_PS_Role
📄 07_SHO_Role
📄 08_Legal_Role
📄 09_AuctionCell_Role
📄 10_Finance_Role
📄 11_Admin_Role
📄 12_Bidder_Public
📄 13_Reports_Dashboards
📄 14_Prototype_Connections
📄 15_Handoff_Notes
```

Each page must contain **Frames** named with prefix:
`[Role]_[ScreenName]_[Breakpoint]`  
Example: `PS_NewSeizure_1440`, `SHO_ApprovalQueue_1440`

---

## 2. Breakpoints & Grid

| Breakpoint | Frame Size | Columns | Gutter | Margin |
|---|---|---|---|---|
| Desktop | 1440 × 1024 | 12 | 24 | 80 |
| Tablet | 1024 × 768 | 8 | 16 | 40 |
| Mobile | 390 × 844 | 4 | 16 | 16 |

**Layout Grid settings in Figma:**
- Desktop: Columns = 12, Width = 80, Gutter = 24, Margin = 80, Type = Stretch
- Tablet: Columns = 8, Width = 88, Gutter = 16, Margin = 40
- Mobile: Columns = 4, Width = 74, Gutter = 16, Margin = 16

**Baseline grid:** 8pt. All spacing must be multiples of 8 (4 allowed for micro-spacing).

---

## 3. Design Tokens (Page 01_Design_Tokens)

Create Figma **Variables** (Local Variables panel) in these collections:

### 3.1 Color Collection — `color`

| Token | Hex | Usage |
|---|---|---|
| `primary/900` | #0B3D2E | Header, sidebar active |
| `primary/700` | #145A43 | Buttons primary |
| `primary/500` | #1E7A5A | Hover |
| `primary/100` | #E6F2ED | Backgrounds |
| `accent/700` | #B8860B | CTA, highlights |
| `accent/500` | #D4A017 | Warnings |
| `neutral/900` | #1A1A1A | Body text |
| `neutral/700` | #4A4A4A | Secondary text |
| `neutral/400` | #9E9E9E | Disabled |
| `neutral/200` | #E0E0E0 | Borders |
| `neutral/50` | #F7F8FA | Page bg |
| `white` | #FFFFFF | Cards |
| `success/600` | #2E7D32 | Eligible, paid |
| `warning/600` | #ED6C02 | Pending notice |
| `error/600` | #C62828 | Blocked, overdue |
| `info/600` | #0277BD | Informational |
| `notice/1` | #E3F2FD | Notice 1 sent |
| `notice/2` | #FFF3E0 | Notice 2 sent |
| `notice/3` | #E8F5E9 | Notice 3 sent |
| `blocked` | #FFEBEE | Eligibility blocked bg |

Create **Modes** under `color` collection:
- Mode 1: `Light` (default)
- Mode 2: `Dark` (optional Phase 2)

### 3.2 Typography Collection — `type`

Font family: **Inter** (fallback: Noto Sans Telugu for Telugu text)

| Token | Size / Line / Weight |
|---|---|
| `display/lg` | 32 / 40 / 700 |
| `display/md` | 28 / 36 / 700 |
| `heading/lg` | 24 / 32 / 600 |
| `heading/md` | 20 / 28 / 600 |
| `heading/sm` | 18 / 24 / 600 |
| `body/lg` | 16 / 24 / 400 |
| `body/md` | 14 / 20 / 400 |
| `body/sm` | 12 / 16 / 400 |
| `label/md` | 14 / 20 / 500 |
| `caption` | 11 / 14 / 500 |
| `mono` | 13 / 20 / 500 (JetBrains Mono for IDs) |

### 3.3 Spacing Collection — `space`
`0, 4, 8, 12, 16, 24, 32, 40, 48, 64, 80`

### 3.4 Radius Collection — `radius`
`none:0, sm:4, md:8, lg:12, xl:16, pill:999`

### 3.5 Shadow Collection — `elevation`
- `sm`: 0 1 2 rgba(0,0,0,0.06)
- `md`: 0 4 8 rgba(0,0,0,0.08)
- `lg`: 0 8 24 rgba(0,0,0,0.12)
- `focus`: 0 0 0 3 rgba(30,122,90,0.35)

### 3.6 Size Collection — `size`
`icon/sm:16, icon/md:20, icon/lg:24, control/sm:32, control/md:40, control/lg:48, sidebar:260, topbar:64`

---

## 4. Component Library (Page 02_Components)

Build each as a **Component** with **Variants** using properties. Name strictly.

### 4.1 Atoms

**Button**
- Properties: `Type` (Primary, Secondary, Ghost, Danger, Link), `Size` (sm, md, lg), `State` (Default, Hover, Pressed, Focus, Disabled, Loading), `Icon` (None, Leading, Trailing, Only)
- Auto layout: Horizontal, gap 8, padding 16/12
- Min width: 88 (sm), 120 (md)

**Input Field**
- Properties: `State` (Default, Focus, Filled, Error, Disabled, Readonly), `Label` (Yes/No), `Helper` (None, Text, Error), `Icon` (None, Leading, Trailing)
- Height: 40 md / 48 lg
- Border: 1px neutral/200; focus 2px primary/700 + shadow focus

**Select / Dropdown**
- Same as Input + chevron trailing

**Checkbox / Radio / Toggle** — standard variants

**Chip / Badge**
- Properties: `Tone` (Neutral, Success, Warning, Error, Info, Notice1, Notice2, Notice3), `Size` (sm, md), `Icon` (None, Dot, Leading)
- Used for: “Notice 1 Sent”, “Eligible”, “Blocked”, “Stay”, “Sold”

**Avatar** — sizes 24/32/40, with role ring color

**Icon** — use Lucide or Material Symbols, 20px default

**Tooltip** — 240 max-width, dark bg

**Stepper / Progress**
- Horizontal numbered steps, states: Done, Current, Upcoming, Error

**Table Cell** — text, chip, action, checkbox variants

**Pagination** — Prev, Next, page numbers, rows-per-page

**Empty State** — illustration + heading + body + CTA

**Skeleton Loader** — line, card, table-row

**Toast / Snackbar** — Success, Error, Warning, Info

**Modal / Dialog**
- Sizes: sm (400), md (560), lg (800), xl (1080)
- Slots: Header (title + close), Body, Footer (actions)

**Drawer (Side Panel)**
- Right-aligned, width 480 / 640, used for vehicle detail quick view

**Tabs** — underline style, states

### 4.2 Molecules

**Top Bar**
- Left: Logo (Telangana Police emblem) + App name “SVAMS”
- Center: Global search
- Right: Language toggle (EN/తె), Notifications bell with badge, Help, Profile menu
- Height 64, bg primary/900, text white

**Side Navigation**
- Width 260, collapsible to 72
- Items with icon + label + optional badge
- Role-based menu (use variants)

**Breadcrumb** — Home / Module / Screen

**Filter Bar**
- Search input + 3–5 filter dropdowns + “Apply” + “Reset” + “Save View”

**KPI Card**
- Title, big value, delta chip, mini sparkline, icon
- Variants: Primary, Success, Warning, Error

**Vehicle Card**
- Thumbnail, Reg No (mono), Make/Model, Category chip, PS name, Notice progress (3 dots), Status chip, CTA

**Notice Progress Tracker**
- 3 connected steps labeled Notice 1 / 2 / 3 with dates below
- States: Not Sent, Sent, Delivered, Returned, Acknowledged
- Color-coded using notice/1,2,3 tokens

**Eligibility Checklist Row**
- Icon (pass/fail/warn), rule label, value, action link

**Auction Lot Card**
- Lot ID, vehicle count, reserve price, date/time, status chip, CTA

**Bid Row**
- Bidder alias, amount, timestamp, H1 badge

**Approval Timeline**
- Vertical stepper: PS → SHO → Legal → Auction Cell → District Admin

**File Upload Tile**
- Drag zone, file name, size, progress, remove

**Data Table**
- Header row (sortable), body rows, sticky first column, row actions, bulk select, pagination
- Variants: Default, Compact, With-expand

### 4.3 Role Shell (Template)

**AppShell** component with slots:
- `Sidebar` (variant per role)
- `Topbar`
- `PageHeader` (Title, Subtitle, Breadcrumb, Primary action)
- `Content`
- `Footer` (version, help)

Variants for each role: PS, SHO, Legal, AuctionCell, Finance, Admin, Bidder, Public.

---

## 5. Screen-by-Screen Specifications

> For every screen: set frame to Desktop 1440×1024, apply 12-col grid, use AppShell component, and add prototype links.

### 5.1 Auth (Page 05_Auth)

**AUTH_Login_1440**
- Split layout: left 55% brand panel (primary/900 bg, emblem, tagline “Seized Vehicle Auction Management”, illustration), right 45% form card.
- Fields: User ID / Mobile, Password, Captcha, Remember me, “Login with OTP”, Forgot password.
- Role selector dropdown (PS, SHO, Legal, Auction Cell, Finance, Admin, Bidder).
- CTA: “Secure Login” (Primary lg).
- Footer: “For official use only • Telangana Police” + IT helpline.

**AUTH_OTP_1440**
- 6 OTP boxes, resend timer 30s, “Verify” CTA, back link.

**AUTH_RoleLanding_1440**
- After login, route to role dashboard. Add prototype conditional: use Figma **Variables + Conditional Logic** (or simulate with separate frames per role).

**AUTH_ForgotPassword_1440**, **AUTH_ResetPassword_1440**

---

### 5.2 Police Station Role (Page 06_PS_Role)

**PS_Dashboard_1440**
- PageHeader: “Police Station Dashboard — [PS Name]”
- 4 KPI cards: Total Seized, Pending Notices, Eligible for Auction, Auctioned
- Notice Compliance widget: donut chart (3/3, 2/3, 1/3, 0/3)
- Recent Seizures table (Reg No, Category, Date, Notice Status, Eligibility, Action)
- Quick actions: “New Seizure Entry”, “Upload Notice Proof”, “View Auction Eligible”

**PS_VehicleList_1440**
- FilterBar: Search (Reg/Chassis/FIR), Category, PS, Date range, Notice Status, Eligibility
- DataTable columns: Checkbox, Reg No, Make/Model, Category chip, Seizure Date, PS, Notice (3-dot tracker), Eligibility chip, Actions (View / Edit / Upload)
- Bulk actions bar appears on selection: Assign, Export, Request Approval
- Pagination

**PS_NewSeizure_1440 (Multi-step Wizard)**
Use Stepper with 6 steps. Each step is its own frame for prototype clarity, but design as one wizard with step variants.

**Step 1 — Vehicle Details**
- Fields: Registration No (with “Fetch from VAHAN” button), Chassis No, Engine No, Make, Model, Year, Type (2W/4W/Commercial/Other), Color, Fuel, Odometer.
- Validation inline.

**Step 2 — Seizure Details**
- Seizure Memo No, Date & Time, Place of Seizure (map picker), Seizure Officer (auto from login), PS (auto), District (auto), Case/FIR No (search), Sections, Investigating Officer.
- Category radio: Victim Vehicle / Crime Vehicle (with helper text explaining difference).
- Custody Location dropdown, Condition notes, Fuel level, Keys (Yes/No), Accessories checklist.

**Step 3 — Owner & RTA Details**
- Auto-filled from VAHAN: Owner Name, Address, Mobile, Email, RC Status, Insurance, Fitness.
- Editable with “Mark as verified” checkbox + verification source + reference no.
- Flag mismatch toggle with reason.

**Step 4 — Documents Upload**
- File Upload Tiles: Seizure Memo (mandatory), RC Copy, Insurance, Permit, Vehicle Photos (min 4: front, rear, left, right), FIR copy, Other.
- Each tile shows status chip: Uploaded / Pending / Rejected.

**Step 5 — Valuation**
- Estimated Value (₹), Valuation Officer Name, Valuation Date, Valuation Report upload, Remarks.

**Step 6 — Review & Submit**
- Read-only summary grouped in cards.
- Checkbox: “I confirm details are accurate.”
- Buttons: Save Draft, Submit for SHO Approval.

**PS_VehicleDetail_1440**
- Tabs: Overview, Seizure & Case, Owner & RTA, Notices, Documents, Valuation, Auction History, Audit Log.
- Header: Reg No (mono), Category chip, Eligibility chip, PS name, Actions (Edit, Upload Notice, Request Approval, Print).
- Overview tab: Vehicle Card + Notice Progress Tracker + Eligibility Checklist + Approval Timeline.

**PS_NoticeTracking_1440**
- Table of vehicles with 3-notice tracker columns.
- Columns: Reg No, Owner, Notice 1 (date/mode/status), Notice 2, Notice 3, Interval OK?, Eligibility, Action.
- Row expand shows proof thumbnails + delivery status.
- CTA: “Record Notice” opens **PS_RecordNotice_Drawer_1440**.

**PS_RecordNotice_Drawer_1440**
- Fields: Notice Number, Notice Type, Sent Date, Mode (Registered Post / Speed Post / Email / SMS / Public Notice / Newspaper), Address, Tracking No, Delivery Status, Acknowledgement Date, Remarks.
- Upload proof (receipt/ack/returned envelope/publication).
- Buttons: Cancel, Save Notice.

**PS_UploadNoticeProof_Modal_1440**
- Drag-drop + file list + “Confirm Upload”.

---

### 5.3 SHO Role (Page 07_SHO_Role)

**SHO_Dashboard_1440**
- KPI: Pending My Approval, Notice Non-Compliance, Eligible Awaiting Approval, Approved This Month.
- Approval queue preview table.
- Alerts panel: “3 vehicles overdue for 3rd notice”.

**SHO_ApprovalQueue_1440**
- Table: Reg No, PS, Category, Notice Compliance (chip), Legal Status, Submitted On, Age, Action (Review).
- Filters: Category, PS, Age, Compliance.

**SHO_ReviewVehicle_1440**
- Left column: Vehicle summary + Notice Progress Tracker + Eligibility Checklist.
- Right column: Approval panel with:
  - Radio: Approve / Reject / Send Back
  - Remarks (required if Reject/Send Back)
  - Digital signature placeholder
  - Buttons: Cancel, Submit Decision.
- Bottom: Approval Timeline + Audit Log preview.

**SHO_NoticeComplianceView_1440**
- List of vehicles grouped by compliance: 3/3, 2/3, 1/3, 0/3.
- Each row expandable to show notice dates, intervals, and rule violations.

---

### 5.4 Legal Role (Page 08_Legal_Role)

**LEGAL_Dashboard_1440**
- KPI: Pending Legal Clearance, Court Stays Active, Claims Received, Cleared This Month.
- Table: Reg No, Case No, Court, Next Hearing, Stay (Y/N), Claim (Y/N), Action.

**LEGAL_CaseDetail_1440**
- Tabs: Case Info, Court Orders, Stays, Claims, Legal Clearance, Documents, Audit.
- Court Order entry: Order No, Date, Court, Judge, Order Type (Stay/Release/Confiscation/Auction Permission), Order Copy upload.
- Legal Clearance panel: Radio (Cleared / Not Cleared / Awaiting), Remarks, Approver, Date.

**LEGAL_ClaimManagement_1440**
- Table of claims: Claimant, Vehicle, Claim Type, Date, Status.
- Drawer: Claim details + documents + decision (Accept/Reject/Escalate).

---

### 5.5 Auction Cell Role (Page 09_AuctionCell_Role)

**AUC_Dashboard_1440**
- KPI: Eligible Vehicles, Active Lots, Upcoming Auctions, Revenue This Month.
- Charts: Auction trend, Revenue by district.
- Table: Upcoming auctions with countdown.

**AUC_EligibleVehicles_1440**
- Table of vehicles with Eligibility = Eligible.
- Filters: Category, PS, District, Reserve price range.
- Bulk action: “Add to Lot”.

**AUC_CreateLot_1440**
- Wizard: Lot Details → Select Vehicles → Pricing → Schedule → Terms → Review.
- Lot Details: Lot ID (auto), Title, Description, Category, District.
- Select Vehicles: searchable table with checkboxes; blocked vehicles show lock icon + reason tooltip.
- Pricing: Reserve price per vehicle, Total reserve, Bid increment, EMD amount.
- Schedule: Start date/time, End date/time, Auto-extension (minutes).
- Terms: rich text editor, attach terms PDF.
- Review: summary + “Publish Lot”.

**AUC_LotDetail_1440**
- Header: Lot ID, Status chip, Countdown timer, Actions (Edit, Publish, Cancel).
- Tabs: Vehicles, Bidders, Bids, Payments, Documents, Audit.
- Vehicles tab: cards with reserve price and eligibility.

**AUC_LiveAuction_1440**
- Left: Lot summary + vehicle carousel.
- Center: Live bid feed (auto-updating list), current H1 amount (huge), bid increment buttons.
- Right: Bidder list, EMD status, controls (Pause, Extend, Close).
- Bottom: Activity log.

**AUC_BidderManagement_1440**
- Table: Bidder, KYC status, EMD status, Lots participated, Won, Blacklist.
- Drawer: Bidder profile + documents + actions.

**AUC_SaleConfirmation_1440**
- H1 bidder details, amount, payment status, buttons: Generate Sale Certificate, Issue Delivery Order, Mark Unsold.

**AUC_UnsoldHandling_1440**
- Options: Re-auction, Scrap, Return to PS, Dispose.

---

### 5.6 Finance Role (Page 10_Finance_Role)

**FIN_Dashboard_1440**
- KPI: EMD Collected, Sale Proceeds, Refunds Pending, Reconciled Today.
- Charts: Daily collection, Payment mode split.

**FIN_Payments_1440**
- Table: Txn ID, Bidder, Lot, Type (EMD/Sale), Amount, Mode, Status, Date.
- Filters: Date, Status, Lot, District.

**FIN_Refunds_1440**
- Table of refunds with approve/reject actions.

**FIN_RevenueReport_1440**
- Filters + table + export (CSV/PDF) + summary cards.

---

### 5.7 Admin Role (Page 11_Admin_Role)

**ADM_Dashboard_1440**
- KPI: Active Users, Vehicles in System, Auctions Run, System Health.

**ADM_UserManagement_1440**
- Table: Name, Role, PS/District, Status, Last Login.
- Drawer: Create/Edit user, assign role, reset password, deactivate.

**ADM_NoticeRules_1440** ⭐ Critical
- Form:
  - Minimum notice count (default 3)
  - Min interval between notices (days)
  - Max interval between notices (days)
  - Total notice duration (days)
  - Min wait after 3rd notice (days)
  - Accepted modes (multi-select chips)
  - Returned undelivered handling (radio: Additional public notice / Escalate / Block)
  - Category-specific overrides (Victim vs Crime) using tabs.
- “Preview rule impact” panel showing how many current vehicles would be affected.
- Save + Audit note.

**ADM_MasterData_1440**
- Tabs: Districts, Police Stations, Courts, Vehicle Types, Document Types, Notice Modes.

**ADM_Integrations_1440**
- Cards: VAHAN, CCTNS, SMS, Email, Payment, e-Sign. Each with status, config, test button.

**ADM_AuditLog_1440**
- Table: Timestamp, User, Role, Action, Entity, Old→New, IP.
- Filters + export.

---

### 5.8 Bidder & Public (Page 12_Bidder_Public)

**BID_Register_1440**
- Steps: Mobile + OTP → Basic details → KYC upload → Bank details → Terms → Done.

**BID_Login_1440** — reuse AUTH_Login with Bidder role.

**BID_Dashboard_1440**
- KPI: Active Bids, Won Lots, EMD Balance, Payments Due.
- Cards: Live auctions, Upcoming auctions, My bids.

**BID_BrowseAuctions_1440**
- FilterBar: District, Category, Vehicle type, Price range, Auction date.
- Grid of Auction Lot Cards.

**BID_LotDetail_1440**
- Vehicle carousel, specs, inspection schedule, terms, EMD button, “Register to Bid”.

**BID_VehicleInspection_1440**
- Slot picker + location + QR pass.

**BID_BiddingScreen_1440**
- Similar to AUC_LiveAuction but bidder view: current H1, my bid, place bid, auto-bid toggle, wallet balance.

**BID_Payment_1440**
- Payment method selection, amount summary, pay CTA, receipt.

**BID_MyWins_1440**
- Won lots table + payment + delivery status + download sale certificate.

**PUBLIC_VehicleStatus_1440**
- Public search by Reg No / Notice No. Shows status: Seized / Notice Sent / Eligible / Auctioned / Released. No personal data.

**PUBLIC_ClaimSubmission_1440**
- Owner/claimant form: Vehicle Reg No, Claimant details, Relationship, Claim type, Documents, Declaration. Submit → generates reference ID.

---

### 5.9 Reports & Dashboards (Page 13_Reports_Dashboards)

**RPT_DistrictDashboard_1440**
- Map of Telangana with district heatmap.
- KPIs + charts + drill-down table.

**RPT_PendingNotices_1440**
- Table + aging buckets + export.

**RPT_EligibilityBlocked_1440**
- Grouped by block reason with counts.

**RPT_AuctionRevenue_1440**
- Time series + district split + export.

**RPT_VehicleAging_1440**
- Buckets: 0–30, 31–60, 61–90, 90+ days.

**RPT_CourtStayClaims_1440**

**RPT_AuditTrail_1440**

Each report: PageHeader + FilterBar + KPI strip + chart + table + export buttons (CSV, PDF, Print).

---

## 6. Prototype Connections (Page 14_Prototype_Connections)

Use **Figma Prototype** panel. Set:

**Global**
- Device: Desktop 1440
- Flow starting points named exactly: `Flow_PS`, `Flow_SHO`, `Flow_Legal`, `Flow_Auction`, `Flow_Finance`, `Flow_Admin`, `Flow_Bidder`, `Flow_Public`.

**Required interactions:**

| From | Trigger | To | Animation |
|---|---|---|---|
| AUTH_Login | Click “Secure Login” | Role dashboard (based on selected role) | Smart Animate, 300ms |
| PS_Dashboard | Click “New Seizure Entry” | PS_NewSeizure Step 1 | Move In Right |
| PS_NewSeizure Step 1 | Click “Next” | Step 2 | Move In Right |
| PS_NewSeizure Step N | Click “Back” | Step N-1 | Move In Left |
| PS_NewSeizure Step 6 | Click “Submit” | PS_VehicleDetail | Smart Animate |
| PS_VehicleDetail | Click “Record Notice” | PS_RecordNotice_Drawer | Slide In Right |
| PS_RecordNotice_Drawer | Click “Save Notice” | PS_NoticeTracking | Smart Animate + Toast |
| PS_VehicleList | Click row | PS_VehicleDetail | Smart Animate |
| SHO_ApprovalQueue | Click “Review” | SHO_ReviewVehicle | Smart Animate |
| SHO_ReviewVehicle | Click “Submit Decision” | SHO_ApprovalQueue | Smart Animate + Toast |
| LEGAL_CaseDetail | Click “Mark Cleared” | LEGAL_Dashboard | Smart Animate |
| AUC_EligibleVehicles | Click “Add to Lot” | AUC_CreateLot | Move In Right |
| AUC_CreateLot | Click “Publish Lot” | AUC_LotDetail | Smart Animate |
| AUC_LotDetail | Click “Go Live” | AUC_LiveAuction | Smart Animate |
| AUC_LiveAuction | Click “Close Lot” | AUC_SaleConfirmation | Smart Animate |
| FIN_Payments | Click row | FIN_PaymentDetail drawer | Slide In Right |
| ADM_NoticeRules | Click “Save” | ADM_NoticeRules with success toast | Smart Animate |
| BID_BrowseAuctions | Click lot | BID_LotDetail | Smart Animate |
| BID_LotDetail | Click “Register to Bid” | BID_BiddingScreen | Smart Animate |
| PUBLIC_VehicleStatus | Click “Submit Claim” | PUBLIC_ClaimSubmission | Move In Right |

**Overlays:** Use Figma **Overlay** for Drawers, Modals, Toasts. Set background `rgba(0,0,0,0.4)`, close on click outside.

**Conditional Logic (Figma feature):**
- On SHO_ReviewVehicle, if Radio = Reject → show Remarks required.
- On PS_NewSeizure, if Category = Victim → show claim period field; if Crime → show court order field.
- On AUC_EligibleVehicles, if Eligibility ≠ Eligible → disable “Add to Lot” and show tooltip.

**Variables for dynamic content:**
- Create variable `currentRole` (PS, SHO, Legal, AuctionCell, Finance, Admin, Bidder).
- Create variable `noticeCount` (0–3) to switch Notice Progress Tracker variants.
- Create variable `eligibilityStatus` (Eligible, Blocked, Pending) to switch chips and CTAs.

**Scroll behavior:** Enable “Scroll to” for long forms. Fix Topbar and Sidebar using **Fixed position** in prototype scroll settings.

---

## 7. Key Micro-interactions & States

Design and prototype these explicitly:

1. **Notice dot animation** — 3 dots fill sequentially when notice saved.
2. **Eligibility gate block** — when user tries to add blocked vehicle to lot, show shake animation + error tooltip: “3 notices not completed. 2/3 sent. 2nd notice interval exceeds 45 days.”
3. **Approval success** — green toast sliding from top-right + checklist item turns green.
4. **Live bid increment** — H1 amount animates up with pulse.
5. **Countdown timer** — on Lot Detail and Live Auction.
6. **Skeleton loading** — on tables and dashboards for 800ms on frame load (simulate with After Delay).
7. **Empty states** — every table/list has an empty state frame.
8. **Error states** — form validation, API failure, payment failure.
9. **Role-based menu swap** — Sidebar component variant changes per role.
10. **Language toggle** — EN/తె switches text (create duplicate frames or use Figma variables with string modes).

---

## 8. Content & Copy Guidelines

- All labels in **English** with Telugu translation keys noted in handoff (e.g., `label.regNo = "Registration Number" / " registration సంఖ్య"`).
- Use realistic Telangana data:
  - Districts: Hyderabad, Warangal, Karimnagar, Nizamabad, Khammam, Rangareddy.
  - PS names: Banjara Hills, Begumpet, Secunderabad, Charminar, Kukatpally.
  - Reg Nos: TS09EA1234, TS10UB5678.
  - FIR Nos: 123/2025, 0456/2024.
- Currency: ₹ with Indian numbering (₹1,25,000).
- Dates: DD-MMM-YYYY (e.g., 12-Sep-2025).
- IDs in mono font.

---

## 9. Accessibility

- Contrast ratio ≥ 4.5:1 for text.
- Focus states visible on all interactive elements (use `focus` shadow token).
- Touch targets ≥ 44×44 on mobile.
- Do not rely on color alone — pair chips with icons/text.
- Provide alt text for all images in Figma (right panel → Accessibility).
- Keyboard order documented in Handoff page.

---

## 10. Handoff Notes (Page 15_Handoff_Notes)

Include:
- **Token export:** Figma Variables → JSON (Tokens Studio or Figma REST).
- **Component inventory** table with name, variant count, used on screens.
- **Screen inventory** with role, route suggestion (e.g., `/ps/seizure/new`), and priority (P0/P1/P2).
- **API touchpoints** per screen (VAHAN fetch, notice save, eligibility check, bid place).
- **Validation rules** per field.
- **Notice rule matrix** (from PRD §9) as a config reference.
- **Prototype walkthrough video** link.
- **Design QA checklist**.

---

## 11. Priority for Prototype Build (P0 Screens Only, if time-boxed)

If you must ship a working prototype fast, build only these 14 P0 screens with full interactions:

1. AUTH_Login
2. PS_Dashboard
3. PS_NewSeizure (all 6 steps)
4. PS_VehicleDetail
5. PS_RecordNotice_Drawer
6. PS_NoticeTracking
7. SHO_ApprovalQueue
8. SHO_ReviewVehicle
9. AUC_EligibleVehicles
10. AUC_CreateLot
11. AUC_LiveAuction
12. ADM_NoticeRules
13. BID_LotDetail
14. BID_BiddingScreen

Everything else can be static frames linked from navigation.

---

## 12. Figma Plugins Recommended

- **Tokens Studio** — token management & export.
- **Unsplash / Content Reel** — realistic vehicle images and Indian names.
- **Iconify** — Lucide/Material icons.
- **Autoflow** — draw prototype flow diagrams on Page 04.
- **Stark** — accessibility contrast checks.
- **Figmotion** — advanced micro-interactions (optional).
- **Data Lab / Google Sheets Sync** — populate tables with realistic data.

---

## 13. Deliverable Checklist

- [ ] 15 pages created with correct naming
- [ ] All color/type/space/radius/shadow variables defined with Light mode
- [ ] Component library with variants documented
- [ ] AppShell template with 8 role variants
- [ ] 14 P0 screens fully designed and interactive
- [ ] All drawers/modals as overlays
- [ ] Conditional logic for notice/eligibility/category
- [ ] Notice Progress Tracker component with 4 states
- [ ] Eligibility Checklist component with pass/fail/warn
- [ ] 8 flow starting points labeled
- [ ] Empty, loading, error states for all tables/forms
- [ ] Telugu translation keys noted
- [ ] Handoff page with token JSON + API map
- [ ] Prototype walkthrough recorded

---