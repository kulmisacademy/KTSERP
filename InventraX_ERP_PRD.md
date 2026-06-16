# KULMIS ERP — Product Requirements Document (PRD)

**Version:** 1.0.0  
**Status:** Draft  
**Last Updated:** 2026-05-26  
**Document Owner:** KULMIS ERP Product Team  
**Classification:** Confidential

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Vision & Goals](#2-product-vision--goals)
3. [Target Market & User Personas](#3-target-market--user-personas)
4. [System Architecture Overview](#4-system-architecture-overview)
5. [User Roles & Permissions](#5-user-roles--permissions)
6. [Functional Requirements](#6-functional-requirements)
   - 6.1 Authentication Module
   - 6.2 Store Setup & Onboarding Module
   - 6.3 Dashboard Module
   - 6.4 Product Management Module
   - 6.5 POS (Point of Sale) Module
   - 6.6 Purchase Management Module
   - 6.7 Inventory Tracking Module
   - 6.8 Debt Management Module
   - 6.9 Expense Management Module
   - 6.10 Accounting Module
   - 6.11 Reports & Analytics Module
   - 6.12 Customer Management Module
   - 6.13 Supplier Management Module
   - 6.14 Notifications Module
   - 6.15 Offline Mode
7. [SaaS Subscription System](#7-saas-subscription-system)
8. [Super Admin Control Panel](#8-super-admin-control-panel)
9. [Non-Functional Requirements](#9-non-functional-requirements)
10. [Database Architecture](#10-database-architecture)
11. [Security Requirements](#11-security-requirements)
12. [UI/UX Requirements](#12-uiux-requirements)
13. [Technology Stack](#13-technology-stack)
14. [Integration Requirements](#14-integration-requirements)
15. [Future Roadmap](#15-future-roadmap)
16. [Acceptance Criteria](#16-acceptance-criteria)
17. [Glossary](#17-glossary)

---

## 1. Executive Summary

KULMIS ERP is a **cloud-native, offline-first, multi-tenant SaaS ERP platform** designed to power retail businesses across Africa and emerging markets. It combines Point of Sale (POS), Inventory Management, Purchase Management, Expense Tracking, Debt Management, and Lite Accounting into one unified, fast, and mobile-friendly application.

The platform is engineered to support **30,000+ stores simultaneously**, with real-time cloud sync, robust offline capabilities, and a powerful Super Admin SaaS management layer. It is built on Flutter (multi-platform frontend) and Supabase/PostgreSQL (backend), using Riverpod for state management and Drift/Isar for local offline storage.

KULMIS ERP is positioned as the **go-to ERP solution for retail businesses** that require enterprise-grade features at an accessible price point, with specific optimizations for Somalia and East African market conditions including support for local mobile money payment systems (EVC Plus, Zaad, Sahal, Edahab).

---

## 2. Product Vision & Goals

### 2.1 Vision Statement

> "To give every retail business — from a mini market in Mogadishu to a pharmacy chain in Nairobi — the power of enterprise-grade ERP on any device, online or offline."

### 2.2 Strategic Goals

| # | Goal | Description |
|---|------|-------------|
| G1 | Simplify Inventory Management | Replace manual stock tracking with real-time, barcode-powered inventory control |
| G2 | Accelerate Sales | Enable sub-3-second barcode checkout on any device |
| G3 | Financial Visibility | Provide profit, expense, and debt tracking in real time |
| G4 | Offline Reliability | Ensure POS operations never stop, even without internet |
| G5 | Scalable SaaS Infrastructure | Support 30,000+ concurrent store tenants |
| G6 | Multi-Platform Access | Run on Android, iOS, Windows, Mac, and Web |
| G7 | AI-Ready Foundation | Architect for future AI analytics and sales prediction modules |

### 2.3 Success Metrics

- Time to complete a barcode sale: **< 3 seconds**
- System uptime: **99.9% SLA**
- Offline sync reliability: **100% data integrity on reconnect**
- Onboarding time for new store: **< 10 minutes**
- Supported concurrent stores: **30,000+**
- Dashboard load time: **< 2 seconds**

---

## 3. Target Market & User Personas

### 3.1 Target Business Types

- Retail stores
- Supermarkets
- Pharmacies
- Electronics shops
- Wholesalers
- Mini markets
- Service businesses

### 3.2 Primary Markets

- Somalia (launch market)
- East Africa (expansion)
- Arabic-speaking African markets (future)

### 3.3 User Personas

#### Persona A — Store Owner (Ali Hassan)
- Age: 35, runs a mid-size supermarket in Mogadishu
- Uses a smartphone and occasionally a Windows laptop
- Needs: Real-time sales data, inventory alerts, employee oversight
- Pain points: Manual stock counting, no visibility into daily profits, staff theft

#### Persona B — Cashier (Fadumo Osman)
- Age: 22, daily POS operator
- Uses the app 8 hours/day on a tablet
- Needs: Fast product search, barcode scanning, smooth checkout
- Pain points: Slow legacy systems, internet outages, complex UI

#### Persona C — Accountant (Mohamed Jama)
- Age: 40, manages finances for 3 stores
- Uses the web version on a laptop
- Needs: Expense summaries, profit/loss reports, debt tracking, export to Excel
- Pain points: No unified financial view, manual data entry

#### Persona D — Platform Admin (SaaS Owner)
- Manages the entire KULMIS ERP platform
- Needs: Subscription management, store monitoring, revenue analytics
- Pain points: No visibility into store health, manual subscription handling

---

## 4. System Architecture Overview

### 4.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                         │
│  Flutter App (Android / iOS / Windows / Mac / Web)      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  POS Module  │  │  Inventory   │  │  Reports     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │         Riverpod State Management Layer            │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │     Local Offline DB (Drift / Isar)                │  │
│  └────────────────────────────────────────────────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ Sync Engine
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   BACKEND LAYER                         │
│              Supabase / PostgreSQL                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Auth (JWT)   │  │ Realtime     │  │ Edge Funcs   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │  Storage     │  │  PostgreSQL  │                     │
│  └──────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Multi-Tenant Architecture

Every database table includes `tenant_id` and `store_id` columns. Row Level Security (RLS) policies ensure strict data isolation between stores. No store can access another store's data under any circumstance.

### 4.3 Offline-First Architecture

```
User Action → Local DB (Drift/Isar) → Immediate UI Response
                     ↓ (background)
              Sync Queue → Conflict Resolver → Cloud DB
```

All write operations first hit the local database, providing instant feedback. A background sync engine queues changes and syncs to Supabase when connectivity is restored, with conflict resolution logic.

---

## 5. User Roles & Permissions

### 5.1 Role Hierarchy

```
Super Admin (Platform Level)
    └── Store Owner (Store Level)
            ├── Cashier (Operations Level)
            └── Accountant (Finance Level)
```

### 5.2 Detailed Permission Matrix

| Feature | Super Admin | Store Owner | Cashier | Accountant |
|---------|:-----------:|:-----------:|:-------:|:----------:|
| Manage all platform stores | ✅ | ❌ | ❌ | ❌ |
| View own store dashboard | ✅ | ✅ | Limited | Limited |
| Manage products | ✅ | ✅ | ❌ | ❌ |
| Create sales / POS | ✅ | ✅ | ✅ | ❌ |
| Scan barcode | ✅ | ✅ | ✅ | ❌ |
| View daily sales | ✅ | ✅ | ✅ | ✅ |
| Delete sales reports | ✅ | ✅ | ❌ | ❌ |
| Edit store settings | ✅ | ✅ | ❌ | ❌ |
| View financial analytics | ✅ | ✅ | ❌ | ✅ |
| Manage expenses | ✅ | ✅ | ❌ | ✅ |
| Manage debts/payments | ✅ | ✅ | ❌ | ✅ |
| Export accounting reports | ✅ | ✅ | ❌ | ✅ |
| Manage employees | ✅ | ✅ | ❌ | ❌ |
| Manage subscriptions | ✅ | Own only | ❌ | ❌ |
| Suspend stores | ✅ | ❌ | ❌ | ❌ |
| View system analytics | ✅ | ❌ | ❌ | ❌ |
| Manage payment gateways | ✅ | ❌ | ❌ | ❌ |
| Modify item price at checkout | ✅ | ✅ | Permission-based | ❌ |

### 5.3 Super Admin Capabilities

The Super Admin is the platform owner with unrestricted access to:

- All store data (read-only analytics, no store data manipulation)
- Subscription and billing control
- Feature flag management per plan
- System health monitoring
- Advertisement/banner management
- Support ticket management
- Global notification broadcasts
- Changelog and update management

---

## 6. Functional Requirements

---

### 6.1 Authentication Module

#### 6.1.1 Login Methods

| Method | Required | Notes |
|--------|----------|-------|
| Email + Password | Yes | Primary login method |
| Phone Number + OTP | Yes | SMS or WhatsApp OTP |
| Remember Me | Yes | Persistent token on device |
| Multi-device Login | Yes | Max 5 active sessions per user |

#### 6.1.2 Session Management

- JWT tokens with refresh mechanism
- Token expiry: 7 days (configurable)
- Session revocation on logout from all devices
- Device fingerprinting for audit logs

#### 6.1.3 Security Controls

- Brute force protection: lock after 5 failed attempts
- Account lockout notification via email
- Password reset via email OTP
- Row Level Security (RLS) enforced at database level

#### 6.1.4 Acceptance Criteria

- [ ] User can log in via email/password in < 2 seconds
- [ ] OTP delivered within 30 seconds
- [ ] Failed login after 5 attempts triggers lockout
- [ ] Sessions persist across app restarts when "Remember Me" is enabled
- [ ] Logout from all devices revokes all active sessions

---

### 6.2 Store Setup & Onboarding Module

#### 6.2.1 Onboarding Flow

New store owners are guided through a step-by-step setup wizard:

**Step 1 — Business Info**
- Store name (required)
- Business type (required) — dropdown: Retail, Supermarket, Pharmacy, Electronics, Wholesale, Mini Market, Service
- Phone number (required)
- Address (required)

**Step 2 — Localization**
- Currency selection (required) — with search
- Tax settings (optional) — tax rate %, tax name, tax-inclusive/exclusive toggle

**Step 3 — Branding**
- Logo upload (optional) — PNG/JPG, max 2MB
- Receipt header text (optional)

**Step 4 — Plan Selection**
- Display available subscription plans
- Free trial auto-activated

#### 6.2.2 Acceptance Criteria

- [ ] Onboarding completed in < 10 minutes by a non-technical user
- [ ] Store is fully operational immediately after onboarding
- [ ] All required fields validated before proceeding to next step
- [ ] Logo uploaded and displayed on receipts within the same session

---

### 6.3 Dashboard Module

#### 6.3.1 KPI Widgets

| Widget | Description | Update Frequency |
|--------|-------------|-----------------|
| Today's Sales | Total sales revenue for today | Real-time |
| Monthly Sales | Revenue for current month | Real-time |
| Profit Summary | Revenue minus COGS and expenses | Real-time |
| Expense Summary | Total expenses today/this month | Real-time |
| Low Stock Products | Products below minimum stock threshold | Real-time |
| Best Selling Products | Top 5 products by quantity sold | Daily |
| Recent Transactions | Last 10 sales | Real-time |
| Debt Summary | Total outstanding customer/supplier debts | Real-time |
| Purchase Summary | Total purchases this month | Real-time |

#### 6.3.2 Charts

- **Sales Chart** — Line chart: Daily sales for last 30 days
- **Revenue Chart** — Bar chart: Monthly revenue comparison (last 12 months)
- **Inventory Analytics** — Pie chart: Category-wise stock distribution

#### 6.3.3 Dashboard Customization

- Store Owner can rearrange and hide/show widgets
- Date range filter applies to all widgets simultaneously

#### 6.3.4 Acceptance Criteria

- [ ] Dashboard loads in < 2 seconds
- [ ] All KPIs reflect real-time data
- [ ] Charts render correctly on both mobile and desktop
- [ ] Low stock alerts visually highlighted in red

---

### 6.4 Product Management Module

#### 6.4.1 Product Fields

| Field | Required | Notes |
|-------|----------|-------|
| Product Name | Yes | Searchable |
| Secondary Name | No | e.g., Arabic/Somali name |
| Barcode | No | Auto-generate or manual entry |
| SKU | No | Store-defined identifier |
| Category | Yes | From category list |
| Brand | No | From brand list |
| Unit Type | Yes | e.g., Piece, Kg, Litre, Box |
| Purchase Price (Cost) | Yes | Used for profit calculation |
| Selling Price | Yes | Default POS price |
| Quantity | Yes | Current stock level |
| Minimum Stock Alert | No | Triggers low stock notification |
| Expiry Date | No | Relevant for pharmacy/food |
| Product Image | No | PNG/JPG, max 2MB |
| Notes | No | Internal notes |

#### 6.4.2 Quick Add Mode (CRITICAL FEATURE)

For fast stock entry when products arrive, a simplified form is presented:

```
┌────────────────────────────────────┐
│  QUICK ADD PRODUCT                 │
│  Product Name: ________________    │
│  Cost Price:   ________________    │
│  Sell Price:   ________________    │
│  Quantity:     ________________    │
│  [Save & Add Another]  [Save]      │
└────────────────────────────────────┘
```

All other fields default to sensible values. This reduces product entry time from 2 minutes to under 20 seconds.

#### 6.4.3 Barcode System

**Supported Barcode Types:**
- CODE128 (general products)
- EAN13 (international retail products)
- QR Code (links, custom data)

**Barcode Features:**

| Feature | Description |
|---------|-------------|
| Auto Generation | System auto-generates CODE128 barcode for new products without one |
| Manual Entry | Store owner can manually enter barcode number |
| Barcode Printing | Print individual or bulk barcode labels |
| Camera Scanning | Scan via device camera using `mobile_scanner` package |
| USB Scanner Support | USB HID barcode scanners treated as keyboard input |

#### 6.4.4 Product Categories & Brands

- Store can create unlimited custom categories
- Store can create unlimited custom brands
- Categories support one level of nesting (parent/sub-category)

#### 6.4.5 Bulk Operations

- Bulk price update (increase/decrease by % or fixed amount)
- Bulk category reassignment
- Bulk stock adjustment
- Import from CSV/Excel

#### 6.4.6 Acceptance Criteria

- [ ] Product created in Quick Add mode in < 20 seconds
- [ ] Barcode auto-generated for products without one
- [ ] Camera scanner recognizes barcode in < 1 second
- [ ] USB scanner input handled without focus issues
- [ ] Low stock alert triggers when quantity falls below minimum
- [ ] Duplicate barcode detection and warning

---

### 6.5 POS (Point of Sale) Module

#### 6.5.1 POS Design Principles

The POS must be:
- **Ultra-fast** — every interaction under 200ms response time
- **Touch-optimized** — large buttons (min 48x48dp), no tiny tap targets
- **Keyboard-optimized** — full keyboard shortcut support for desktop
- **Offline-capable** — works 100% without internet connection
- **Distraction-free** — minimal UI during active sales

#### 6.5.2 POS Layout (Main Screen)

```
┌────────────────────────────────────────────────────────┐
│ [🔍 Search / Scan Barcode]          [Customer] [Notes] │
├──────────────────────────┬─────────────────────────────┤
│                          │  CART                       │
│  PRODUCT GRID            │  ─────────────────────────  │
│  [Product 1] [Product 2] │  Item 1   x2   $20.00  [x] │
│  [Product 3] [Product 4] │  Item 2   x1   $15.00  [x] │
│  [Product 5] [Product 6] │  ─────────────────────────  │
│                          │  Subtotal:         $35.00   │
│  [Category Filter]       │  Discount:         -$2.00   │
│                          │  Tax:               $1.50   │
│                          │  TOTAL:            $34.50   │
│                          │  ─────────────────────────  │
│                          │  [💵 Cash] [📱 Mobile] [🏦] │
│                          │  [Charge] [Hold] [Void]     │
└──────────────────────────┴─────────────────────────────┘
```

#### 6.5.3 Product Search & Selection

Users can add products via:
1. **Barcode scan** — camera or USB scanner
2. **Name search** — fuzzy search, results appear as-you-type
3. **SKU search**
4. **Category browse** — visual grid of products by category

#### 6.5.4 Barcode Sales Workflow (CRITICAL)

```
Scan Barcode
    │
    ├─ Product exists in DB?
    │       YES → Add to cart (or +1 if already in cart)
    │       NO  → Prompt: "Product not found. Add new?"
    │
    └─ Product added → Price displayed → Cart updated → Ready for next scan
```

Total workflow time target: **< 1 second per item**

#### 6.5.5 Cart Features

| Feature | Description |
|---------|-------------|
| Change Quantity | Tap quantity field → numpad appears |
| Change Selling Price | Override price for this transaction |
| Apply Item Discount | Percentage or fixed amount per item |
| Apply Order Discount | Percentage or fixed amount on total |
| Remove Item | Swipe left or tap X |
| Add Tax | Tax rate applied (from store settings or per-transaction) |
| Add Customer | Link sale to customer profile |
| Add Notes | Internal note for this sale |
| Hold Sale | Pause and start a new cart |
| Void Sale | Cancel entire transaction |

**IMPORTANT:** Cashiers can modify item price at the cart level (permission-based). Store owner can enable/disable this per role.

#### 6.5.6 Direct Sale (No Product Registration)

For emergency or one-time items:

```
┌────────────────────────────────┐
│  DIRECT SALE                   │
│  Item Name:  ______________    │
│  Price:      ______________    │
│  Quantity:   ______________    │
│  [Add to Cart]                 │
└────────────────────────────────┘
```

This does NOT update inventory. Recorded as "unregistered item" in reports.

#### 6.5.7 Payment Methods

| Method | Description |
|--------|-------------|
| Cash | Manual cash entry, change calculated automatically |
| Mobile Money | EVC Plus, Zaad, Sahal, Edahab |
| Bank Transfer | Manual confirmation |
| Mixed Payment | Split across multiple methods |

For mixed payment:
```
Total: $100
Cash paid: $60
Mobile Money: $40
Remaining: $0 ✅
```

#### 6.5.8 Receipt System

**Receipt Contents:**
- Store logo
- Store name, address, phone
- Invoice number (auto-incrementing)
- Date and time
- Cashier name
- Customer name (if linked)
- Itemized product list with prices
- Discounts applied
- Tax breakdown
- Total paid
- Payment method(s)
- Change given
- QR code (links to digital receipt)
- Return policy footer

**Print Methods:**

| Method | Format | Notes |
|--------|--------|-------|
| Thermal Printer | 58mm / 80mm | Auto-detect width |
| A4 Printer | Full page | Professional layout |
| PDF Export | Digital file | Share via WhatsApp/Email |
| Email Receipt | Sent to customer | If email on profile |

#### 6.5.9 POS Keyboard Shortcuts (Desktop)

| Key | Action |
|-----|--------|
| F1 | Focus barcode/search field |
| F2 | Add new direct sale item |
| F10 | Proceed to payment |
| ESC | Cancel/clear |
| Enter | Confirm quantity |
| Ctrl+H | Hold current sale |

#### 6.5.10 Acceptance Criteria

- [ ] Barcode scan to cart addition: < 1 second
- [ ] Checkout with cash payment: < 10 seconds total
- [ ] Offline sale works identically to online sale
- [ ] Receipt prints within 3 seconds of payment confirmation
- [ ] Mixed payment correctly calculates split
- [ ] Price override logged in audit trail
- [ ] Held sales recoverable after app restart

---

### 6.6 Purchase Management Module

#### 6.6.1 Add Purchase

When stock arrives from supplier:

| Field | Required | Notes |
|-------|----------|-------|
| Supplier | Yes | From supplier list |
| Product | Yes | Existing or create new |
| Quantity | Yes | Units received |
| Purchase Price | Yes | Cost per unit this purchase |
| Selling Price | No | Update product selling price |
| Barcode | No | Assign/update barcode |
| Invoice Number | No | Supplier invoice reference |
| Purchase Date | Yes | Defaults to today |
| Notes | No | Internal notes |

#### 6.6.2 Purchase Effects

When a purchase is saved:
1. Product stock quantity automatically increases
2. Purchase recorded in purchase history
3. If supplier doesn't have enough to pay immediately → Supplier debt created
4. If new product → Option to auto-create product record

#### 6.6.3 Purchase History

- Searchable by supplier, product, date range
- Total cost per purchase
- Profit margin calculator (Purchase Price vs Selling Price)
- Export to PDF/Excel

#### 6.6.4 Supplier Debt Tracking

- When purchase paid partially → remaining balance tracked as supplier debt
- Payment schedule support
- Auto-reminders for upcoming payment due dates

#### 6.6.5 Acceptance Criteria

- [ ] Stock level updates immediately upon purchase save
- [ ] Supplier debt created automatically on partial payment
- [ ] Purchase history searchable by date, supplier, product
- [ ] Import purchases from CSV for bulk entry

---

### 6.7 Inventory Tracking Module

#### 6.7.1 Features

| Feature | Description |
|---------|-------------|
| Real-Time Stock Levels | Live quantity for every product |
| Low Stock Alerts | Notification when quantity < minimum |
| Inventory Adjustments | Manual stock corrections with reason codes |
| Damaged Stock Tracking | Record damaged/expired removed stock |
| Expiry Tracking | Alerts for products expiring within 30/7 days |
| Product Movement History | Full log of every stock change with user, date, reason |
| Stock Valuation | Total inventory value at cost and at retail |

#### 6.7.2 Adjustment Reason Codes

- Damaged goods
- Expired goods
- Theft/shrinkage
- Supplier return
- Stock count correction
- Initial stock entry

#### 6.7.3 Inventory Count (Stocktake)

- Full store count workflow
- Count by category
- Variance report (expected vs actual)
- Auto-adjustment on count completion

#### 6.7.4 Acceptance Criteria

- [ ] Stock level updates in real-time after every sale and purchase
- [ ] Low stock notification sent within 60 seconds of threshold breach
- [ ] Every stock adjustment includes user ID, timestamp, and reason
- [ ] Expiry alerts sent 30 days and 7 days before expiry date

---

### 6.8 Debt Management Module

#### 6.8.1 Debt Types

**Customer Debts** — when customer buys on credit  
**Supplier Debts** — when store doesn't pay supplier in full

#### 6.8.2 Debt Record Fields

| Field | Description |
|-------|-------------|
| Debtor | Customer or Supplier name |
| Original Amount | Total debt created |
| Amount Paid | Running total of payments |
| Remaining Balance | Original - Paid |
| Due Date | When full payment expected |
| Status | Active / Partially Paid / Paid |
| Notes | Any relevant information |

#### 6.8.3 Payment Features

- Record partial payments (installments)
- Full payment marks debt as closed
- Payment history per debt record
- Print debt statement for customer
- Overdue debt highlighted and notified

#### 6.8.4 Debt Reports

- Total outstanding customer debts
- Total outstanding supplier debts
- Overdue debts (past due date)
- Monthly debt collection report

#### 6.8.5 Acceptance Criteria

- [ ] Debt created automatically when credit sale recorded in POS
- [ ] Partial payment updates remaining balance instantly
- [ ] Overdue debts flagged in dashboard
- [ ] Debt statement printable as PDF

---

### 6.9 Expense Management Module

#### 6.9.1 Expense Entry Fields

| Field | Required | Notes |
|-------|----------|-------|
| Expense Name | Yes | Description of expense |
| Category | Yes | From category list |
| Amount | Yes | |
| Date | Yes | Defaults to today |
| Paid By | No | Staff member or owner |
| Receipt Image | No | Photo of physical receipt |
| Notes | No | |

#### 6.9.2 Expense Categories

Default categories (customizable):
- Rent
- Electricity
- Water
- Staff Salary
- Internet
- Transport
- Packaging
- Maintenance
- Miscellaneous

#### 6.9.3 Expense Reports

- Daily expense summary
- Monthly expense breakdown by category
- Year-to-date expense totals
- Expense vs Revenue comparison chart

#### 6.9.4 Acceptance Criteria

- [ ] Expense recorded in < 30 seconds
- [ ] Receipt photo attached and stored in cloud storage
- [ ] Expenses reflected immediately in profit/loss calculation
- [ ] Monthly summary exportable as PDF

---

### 6.10 Accounting Module

A "Lite" accounting module providing essential financial overview without full double-entry bookkeeping.

#### 6.10.1 Features

| Feature | Description |
|---------|-------------|
| Income Tracking | All sales revenue auto-recorded |
| Expense Tracking | All expenses auto-recorded |
| Profit/Loss Report | Revenue - COGS - Expenses = Net Profit |
| Cash Flow Report | Money in vs money out by time period |
| Ledger View | Chronological list of all financial transactions |

#### 6.10.2 Profit Calculation

```
Gross Revenue         = Total Sales (all payment methods)
Cost of Goods Sold    = Sum of (Purchase Price × Quantity Sold)
Gross Profit          = Gross Revenue - COGS
Operating Expenses    = Sum of all expenses in period
Net Profit            = Gross Profit - Operating Expenses
```

#### 6.10.3 Reporting Periods

- Today
- This week
- This month
- Custom date range
- Year to date

#### 6.10.4 Acceptance Criteria

- [ ] Profit/Loss report accurate to within 0.01 of currency unit
- [ ] All sales auto-posted to income ledger
- [ ] All purchases auto-posted to expense/COGS ledger
- [ ] Report exportable as PDF and Excel

---

### 6.11 Reports & Analytics Module

#### 6.11.1 Available Reports

| Report | Description | Export |
|--------|-------------|--------|
| Daily Sales Report | All sales for selected day | PDF, Excel |
| Monthly Sales Report | Sales summary by month | PDF, Excel, CSV |
| Profit Report | Revenue, COGS, gross profit | PDF, Excel |
| Inventory Report | Current stock levels, valuation | PDF, Excel |
| Expense Report | All expenses by category/date | PDF, Excel |
| Debt Report | All outstanding debts | PDF |
| Purchase Report | All purchases from suppliers | PDF, Excel |
| Tax Report | Tax collected by period | PDF, Excel |
| Best Sellers | Top products by quantity/revenue | PDF |
| Customer Report | Sales per customer | PDF |

#### 6.11.2 Chart Types

- **Line charts** — Sales trends over time
- **Bar charts** — Monthly comparisons
- **Pie charts** — Category distribution
- **Donut charts** — Payment method breakdown

#### 6.11.3 Export Options

| Format | Use Case |
|--------|----------|
| PDF | Sharing, printing, archiving |
| Excel (.xlsx) | Further analysis, accountants |
| CSV | Data import to other systems |

#### 6.11.4 Acceptance Criteria

- [ ] All reports load in < 3 seconds for up to 1 year of data
- [ ] PDF export generates and downloads in < 5 seconds
- [ ] Charts render correctly on mobile (responsive)
- [ ] Date range filter applies to all report types

---

### 6.12 Customer Management Module

#### 6.12.1 Customer Profile Fields

- Full name
- Phone number
- Email address (optional)
- Address (optional)
- Date of birth (optional, for loyalty)
- Customer group/segment

#### 6.12.2 Customer Features

| Feature | Description |
|---------|-------------|
| Purchase History | All transactions linked to customer |
| Total Spent | Lifetime spending amount |
| Debt Balance | Current outstanding debt |
| Loyalty Points | Points earned per purchase |
| Blacklist | Mark customer as blocked from credit |

#### 6.12.3 Customer Search

- Search by name (partial match)
- Search by phone number
- Search by customer ID

#### 6.12.4 Acceptance Criteria

- [ ] Customer linked to sale in < 5 seconds
- [ ] Purchase history loads for any customer in < 2 seconds
- [ ] Loyalty points calculated automatically on sale completion

---

### 6.13 Supplier Management Module

#### 6.13.1 Supplier Profile Fields

- Supplier name
- Contact person
- Phone number
- Email
- Address
- Product categories supplied
- Payment terms (e.g., 30 days)

#### 6.13.2 Supplier Features

| Feature | Description |
|---------|-------------|
| Purchase History | All purchases from supplier |
| Total Purchased | Lifetime purchase value |
| Debt Balance | Amount owed to supplier |
| Payment History | All payments made to supplier |

#### 6.13.3 Acceptance Criteria

- [ ] Supplier record created in < 60 seconds
- [ ] Supplier debt visible in real-time
- [ ] Purchase history filterable by date range

---

### 6.14 Notifications Module

#### 6.14.1 Notification Types

| Type | Trigger | Audience |
|------|---------|----------|
| Low Stock Alert | Product quantity < minimum | Store Owner |
| Debt Due Reminder | Debt due date is 3 days away | Store Owner, Accountant |
| Subscription Expiry | 7 days and 1 day before expiry | Store Owner |
| Daily Sales Summary | End of business day | Store Owner |
| Overdue Debt Alert | Debt past due date | Store Owner, Accountant |
| Product Expiry Alert | 30 days, 7 days before expiry | Store Owner |
| System Announcement | Platform-wide message | All users |

#### 6.14.2 Delivery Channels

| Channel | Status |
|---------|--------|
| In-App Push Notification | V1 |
| Email | V1 |
| SMS | V2 (Future) |
| WhatsApp | V2 (Future) |

#### 6.14.3 Notification Preferences

- User can enable/disable each notification type
- Quiet hours support (e.g., no notifications 10pm–7am)
- Notification history log (last 90 days)

#### 6.14.4 Acceptance Criteria

- [ ] Low stock notification delivered within 60 seconds of trigger
- [ ] Notification history accessible in-app
- [ ] User preferences respected (disabled notifications not delivered)

---

### 6.15 Offline Mode

#### 6.15.1 Offline Capabilities (CRITICAL)

The following features MUST work without internet connection:

| Feature | Offline | Notes |
|---------|---------|-------|
| POS Sales | ✅ Full | Complete sale, print receipt |
| Barcode Scanning | ✅ Full | Uses local product database |
| Product Search | ✅ Full | Searches local cache |
| Receipt Printing | ✅ Full | Direct to local printer |
| View Inventory | ✅ Full | Shows last synced data |
| View Reports | ✅ Partial | Last synced data only |
| Add Products | ✅ Full | Queued for sync |
| Manage Expenses | ✅ Full | Queued for sync |

#### 6.15.2 Sync Architecture

```
OFFLINE STATE:
All changes → Local DB (Drift/Isar) → Sync Queue

ONLINE STATE:
Sync Engine → Process Queue → Cloud DB → Resolve Conflicts
```

#### 6.15.3 Conflict Resolution Rules

| Conflict Type | Resolution |
|---------------|------------|
| Same product sold offline on two devices | Sum quantities |
| Product edited on both offline and online | Last-write-wins with user notification |
| Stock adjusted offline then online | Offline adjustment applied as delta |

#### 6.15.4 Sync Indicators

- **Green dot** — Online, synced
- **Yellow dot** — Online, syncing
- **Red dot** — Offline, changes queued
- **Number badge** — Count of unsynced transactions

#### 6.15.5 Acceptance Criteria

- [ ] Full POS sale completed with zero internet connectivity
- [ ] All offline sales synced to cloud within 30 seconds of reconnection
- [ ] No data loss on any offline-to-online transition
- [ ] User notified of sync conflicts with options to resolve
- [ ] Local database supports 100,000+ product records efficiently

---

## 7. SaaS Subscription System

### 7.1 Plans

| Feature | Free Trial | Starter | Business | Enterprise |
|---------|:----------:|:-------:|:--------:|:----------:|
| Duration | 14 days | Monthly/Yearly | Monthly/Yearly | Monthly/Yearly |
| Stores | 1 | 1 | 1–3 | Unlimited |
| Users per store | 2 | 3 | 10 | Unlimited |
| Products | 100 | 1,000 | 10,000 | Unlimited |
| POS | ✅ | ✅ | ✅ | ✅ |
| Barcode | ✅ | ✅ | ✅ | ✅ |
| Offline Mode | ❌ | ✅ | ✅ | ✅ |
| Reports Export | ❌ | Basic | Full | Full |
| Accounting | ❌ | ❌ | ✅ | ✅ |
| AI Analytics | ❌ | ❌ | ❌ | ✅ |
| Priority Support | ❌ | ❌ | ✅ | ✅ |
| Custom Branding | ❌ | ❌ | ✅ | ✅ |

### 7.2 Billing

- Monthly and yearly billing options
- Yearly billing offers 2 months free (equivalent to 16.7% discount)
- Auto-renewal with 7-day and 1-day advance notification
- Grace period: 3 days after expiry before features locked
- Downgrade at end of current billing period only

### 7.3 Payment Gateways

| Gateway | Region | Type |
|---------|--------|------|
| Stripe | International | Card, SEPA |
| EVC Plus | Somalia | Mobile Money |
| Zaad | Somalia (Telesom) | Mobile Money |
| Sahal | Somalia (Golis) | Mobile Money |
| Edahab | Somalia (Hormuud) | Mobile Money |

### 7.4 Subscription Enforcement

- Feature flags checked on every module load
- Graceful degradation: user shown upgrade prompt instead of hard error
- Store owner can view current plan limits vs usage in settings

---

## 8. Super Admin Control Panel

### 8.1 Dashboard Metrics

| Metric | Description |
|--------|-------------|
| Total Stores | All registered stores (active + inactive) |
| Active Subscriptions | Stores with valid paid plan |
| Monthly Recurring Revenue (MRR) | Total subscription revenue this month |
| Active Users | Users logged in within last 24 hours |
| New Stores Today | Stores registered in last 24 hours |
| Churned Stores | Stores that cancelled this month |
| Sales Processed | Total transaction volume across platform |

### 8.2 Store Management

- View all stores with search and filter (by plan, status, country, date)
- View individual store profile (owner, plan, usage, last activity)
- Approve stores (if approval flow enabled)
- Suspend stores (with reason, notification sent to owner)
- Delete stores (soft delete with 30-day recovery window)
- Upgrade/downgrade store plan manually
- Send message to store owner

### 8.3 Subscription & Revenue

- Create custom plans
- Apply promo codes and discounts
- View revenue by plan, by month, by country
- MRR and ARR graphs
- Churn rate and retention analytics
- Failed payment detection and retry management

### 8.4 Feature Control (Feature Flags)

Super Admin can enable/disable per plan:

- POS module
- Barcode scanning
- Full reports & export
- Offline mode
- Accounting module
- AI analytics
- Multi-user
- API access

### 8.5 User Analytics

- Daily active users (DAU)
- Monthly active users (MAU)
- Session duration averages
- Most used features
- Geographic distribution of stores

### 8.6 System Health Monitoring

| Monitor | Metric |
|---------|--------|
| Database | Query performance, connection pool, storage used |
| API | Response times, error rates, throughput |
| Storage | Total files stored, CDN bandwidth |
| Sync Engine | Pending sync queue size, average sync time |
| Error Logs | Real-time error stream with severity levels |

### 8.7 Content Management

- Manage in-app advertisements and banners
- Create and publish changelogs/release notes
- Manage FAQ / Help Center content
- Support ticket queue management

### 8.8 Acceptance Criteria

- [ ] Super Admin can suspend a store within 3 clicks
- [ ] Revenue dashboard updates in real-time
- [ ] Feature flags apply within 60 seconds of change
- [ ] All store actions logged in admin audit trail

---

## 9. Non-Functional Requirements

### 9.1 Performance

| Requirement | Target |
|-------------|--------|
| App startup time | < 3 seconds on mid-range device |
| Dashboard load time | < 2 seconds |
| Barcode scan response | < 1 second |
| POS checkout | < 3 seconds end-to-end |
| Report generation | < 5 seconds for 12-month data |
| API response time (P95) | < 500ms |
| Concurrent stores supported | 30,000+ |
| Concurrent users per store | 50+ |

### 9.2 Scalability

- Horizontal scaling via Supabase Edge Functions
- Database connection pooling via PgBouncer
- Read replicas for report-heavy queries
- CDN for all static assets and product images
- Pagination on all list views (max 50 items per page)

### 9.3 Reliability

- Platform uptime: 99.9% SLA (< 8.7 hours downtime/year)
- Data backup: Hourly incremental, daily full backup
- Backup retention: 30 days
- RTO (Recovery Time Objective): < 4 hours
- RPO (Recovery Point Objective): < 1 hour

### 9.4 Offline Reliability

- Offline database supports minimum 30 days of local data
- No data loss on connectivity transitions
- Sync queue persists across app restarts and device reboots

### 9.5 Localization

- Language: English (V1), Somali (V1.5), Arabic (V2)
- Currency: Any (configured per store)
- Date/Time: Store locale (configurable)
- RTL layout support (V2)

---

## 10. Database Architecture

### 10.1 Multi-Tenant Structure

Every table in the database MUST include:

```sql
tenant_id    UUID    NOT NULL  -- Platform-level tenant
store_id     UUID    NOT NULL  -- Store within tenant
created_at   TIMESTAMPTZ DEFAULT NOW()
updated_at   TIMESTAMPTZ DEFAULT NOW()
```

### 10.2 Row Level Security (RLS)

All tables enforce RLS policies:

```sql
-- Users can only access their own store's data
CREATE POLICY store_isolation ON products
  USING (store_id = auth.jwt() ->> 'store_id');
```

### 10.3 Core Tables

| Table | Purpose |
|-------|---------|
| `tenants` | SaaS tenant (subscription holder) |
| `stores` | Individual store records |
| `users` | All platform users |
| `user_roles` | Role assignments per store |
| `products` | Product catalog |
| `categories` | Product categories |
| `brands` | Product brands |
| `inventory` | Current stock levels |
| `inventory_movements` | All stock changes log |
| `sales` | Sale headers |
| `sale_items` | Line items for each sale |
| `purchases` | Purchase headers |
| `purchase_items` | Line items for each purchase |
| `suppliers` | Supplier records |
| `customers` | Customer records |
| `debts` | Debt records (customer & supplier) |
| `debt_payments` | Payment history for debts |
| `expenses` | Expense records |
| `subscriptions` | Active subscription records |
| `subscription_plans` | Available plan definitions |
| `notifications` | Notification records |
| `audit_logs` | All user actions for security |

### 10.4 Indexing Strategy

Performance-critical indexes:

```sql
-- Product search
CREATE INDEX idx_products_name ON products USING gin(to_tsvector('english', name));
CREATE INDEX idx_products_barcode ON products (barcode, store_id);

-- Sales queries
CREATE INDEX idx_sales_store_date ON sales (store_id, created_at DESC);

-- Inventory movements
CREATE INDEX idx_inventory_product ON inventory_movements (product_id, created_at DESC);
```

---

## 11. Security Requirements

### 11.1 Authentication Security

- Passwords hashed with bcrypt (min cost 12)
- JWT tokens signed with RS256
- Refresh tokens rotated on every use
- Rate limiting: 10 requests/minute on auth endpoints

### 11.2 Data Security

- All data encrypted at rest (AES-256)
- All data encrypted in transit (TLS 1.3)
- PII fields (customer phone, email) encrypted at column level
- Backups encrypted with separate key

### 11.3 Access Control

- Row Level Security enforced on ALL tables
- API endpoints validate JWT on every request
- No client-side authorization checks (server-side only)
- Permission changes take effect immediately (no token re-issue delay)

### 11.4 Audit & Compliance

- All user actions logged: user ID, action, timestamp, IP address, device
- Audit logs immutable (append-only, no delete)
- Audit log retention: 2 years
- GDPR-compliant data deletion (on request, within 30 days)

### 11.5 Vulnerability Management

- Dependency scanning in CI/CD pipeline
- Penetration testing before major releases
- Responsible disclosure policy published
- Security patches deployed within 72 hours of critical CVE

---

## 12. UI/UX Requirements

### 12.1 Design Principles

1. **Speed first** — every interaction must feel instant
2. **Minimal learning curve** — a non-technical store owner should operate the full app within 1 hour
3. **Mobile-first** — designed for phones first, scaled to tablets and desktop
4. **Accessibility** — minimum AA WCAG 2.1 compliance
5. **Consistency** — same patterns across all modules

### 12.2 Theme

| Attribute | Spec |
|-----------|------|
| Primary Color | Deep Blue `#1A3C6E` |
| Accent Color | Emerald Green `#00A878` |
| Error Color | Red `#E53935` |
| Warning Color | Amber `#FFA000` |
| Background (Light) | `#F5F7FA` |
| Background (Dark) | `#121212` |
| Typography | Inter (primary), Roboto Mono (numbers) |
| Border Radius | 8dp (cards), 4dp (inputs) |
| Elevation | Material Design 3 tokens |

### 12.3 Themes

- Light mode (default)
- Dark mode (system-auto and manual toggle)

### 12.4 POS-Specific UI Rules

- Minimum button size: 48×48dp (touch targets)
- Font size for prices: minimum 20sp
- Cart item rows: minimum 56dp height
- Barcode input field always visible and focusable
- Numeric keyboard shown automatically for quantity and price fields

### 12.5 Responsive Breakpoints

| Breakpoint | Target Devices |
|------------|---------------|
| < 480px | Phones (portrait) |
| 480–840px | Phones (landscape), small tablets |
| 840–1200px | Tablets, iPads |
| > 1200px | Desktop, large tablets |

---

## 13. Technology Stack

### 13.1 Frontend

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Framework | Flutter 3.x | Cross-platform (Android, iOS, Windows, Mac, Web) |
| State Management | Riverpod 2.x | Scalable, testable, compile-safe |
| Navigation | go_router | Declarative, deep link support |
| Code Generation | freezed + json_serializable | Immutable models, boilerplate reduction |
| Offline Database | Drift (SQLite) | Type-safe SQL, excellent Flutter integration |
| Backend SDK | supabase_flutter | Auth, realtime, storage |

### 13.2 Backend

| Service | Technology |
|---------|-----------|
| Database | PostgreSQL 15 (via Supabase) |
| Authentication | Supabase Auth (JWT) |
| Real-time | Supabase Realtime (WebSockets) |
| Storage | Supabase Storage (S3-compatible) |
| Serverless | Supabase Edge Functions (Deno) |
| CDN | Supabase CDN |

### 13.3 Key Flutter Packages

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `freezed` | Immutable data classes |
| `supabase_flutter` | Backend integration |
| `drift` | Local SQLite database |
| `mobile_scanner` | Barcode/QR scanning |
| `barcode_widget` | Barcode generation/display |
| `syncfusion_flutter_charts` | Analytics charts |
| `pdf` | PDF generation |
| `printing` | Print to thermal/A4 |
| `flutter_local_notifications` | Local push notifications |
| `image_picker` | Photo capture for receipts, products |
| `share_plus` | Share PDF receipts |
| `intl` | Localization, number/date formatting |

### 13.4 Development & DevOps

| Tool | Purpose |
|------|---------|
| GitHub | Source control |
| GitHub Actions | CI/CD pipeline |
| Fastlane | Mobile deployment automation |
| Sentry | Error monitoring & crash reporting |
| Mixpanel / PostHog | Product analytics |
| Supabase Dashboard | Database management |

---

## 14. Integration Requirements

### 14.1 Payment Gateway Integrations

| Gateway | API | Status |
|---------|-----|--------|
| Stripe | REST API | V1 |
| EVC Plus | Hormuud API | V1 |
| Zaad | Telesom API | V1 |
| Sahal | Golis API | V1 |
| Edahab | Hormuud API | V1 |

### 14.2 Hardware Integrations

| Hardware | Protocol | Status |
|----------|----------|--------|
| USB Barcode Scanner | HID (Keyboard emulation) | V1 |
| Bluetooth Barcode Scanner | BLE | V1.5 |
| Thermal Printer (ESC/POS) | USB / Bluetooth / Network | V1 |
| A4 Printer | OS print dialog | V1 |
| Cash Drawer | ESC/POS command | V1.5 |
| Customer Display | Serial / USB | V2 |

### 14.3 Export Integrations

| Format | Module | Status |
|--------|--------|--------|
| Excel (.xlsx) | Reports, Inventory | V1 |
| PDF | All modules | V1 |
| CSV | Reports | V1 |
| WhatsApp | Receipts | V2 |
| Email | Receipts, Reports | V1 |

---

## 15. Future Roadmap

### V1.5 (3–6 months post-launch)
- Multi-language support (Somali, Arabic)
- WhatsApp receipt delivery
- SMS notifications
- Bluetooth scanner support
- Cash drawer integration
- Loyalty program (points redemption at POS)

### V2.0 (6–12 months post-launch)
- Multi-currency per store
- E-commerce integration (online store)
- RTL layout (Arabic)
- Advanced user permissions (custom roles)
- Multi-store management (one owner, multiple stores)
- Franchise management tools

### V3.0 (12–24 months post-launch)
- AI Sales Prediction (OpenAI integration)
- Smart Inventory Forecasting
- Product Demand Analytics
- AI Business Insights dashboard
- Voice assistant (product search by voice)
- NFC payments
- Biometric login (fingerprint, face ID)
- API for third-party integrations
- Webhook system for enterprise integrations

---

## 16. Acceptance Criteria

### 16.1 System-Level Acceptance Criteria

| ID | Criterion | Priority |
|----|-----------|----------|
| AC-01 | Full POS sale (barcode scan to receipt print) completed in < 10 seconds | Critical |
| AC-02 | POS operates fully offline with no internet connectivity | Critical |
| AC-03 | All offline data synced to cloud within 30 seconds of reconnection | Critical |
| AC-04 | No data loss across offline-to-online transitions (100% integrity) | Critical |
| AC-05 | System handles 30,000 concurrent store tenants without degradation | Critical |
| AC-06 | Store owner completes onboarding in < 10 minutes | High |
| AC-07 | Dashboard loads in < 2 seconds | High |
| AC-08 | Reports export to PDF in < 5 seconds | High |
| AC-09 | All user roles enforce correct permissions | Critical |
| AC-10 | RLS prevents any cross-store data access | Critical |
| AC-11 | Barcode scan recognized in < 1 second | High |
| AC-12 | Subscription plan limits enforced in real-time | High |
| AC-13 | Super Admin can suspend store within 60 seconds | Medium |
| AC-14 | App runs on Android, iOS, Windows, Mac, and Web | High |
| AC-15 | All financial calculations accurate to 2 decimal places | Critical |

---

## 17. Glossary

| Term | Definition |
|------|-----------|
| **Tenant** | A subscription holder on the KULMIS ERP platform. May own one or more stores. |
| **Store** | A single business unit (e.g., one shop location). Each store has independent data. |
| **RLS** | Row Level Security — PostgreSQL feature that restricts data access at the row level. |
| **MRR** | Monthly Recurring Revenue — total subscription revenue per month. |
| **POS** | Point of Sale — the system used to process customer sales transactions. |
| **COGS** | Cost of Goods Sold — the purchase cost of products that were sold. |
| **SKU** | Stock Keeping Unit — a store-defined internal product identifier. |
| **EAN13** | European Article Number — 13-digit barcode standard used on retail products. |
| **CODE128** | A high-density barcode standard supporting alphanumeric characters. |
| **Drift** | A type-safe SQLite ORM for Flutter used for offline local database. |
| **Riverpod** | A compile-safe state management library for Flutter. |
| **Edge Functions** | Serverless functions running at Supabase's edge nodes. |
| **Sync Engine** | The background service that synchronizes local offline data with the cloud. |
| **Feature Flag** | A configuration switch that enables/disables a feature for specific plans or users. |
| **JWT** | JSON Web Token — a secure token standard used for authentication. |
| **MoMo** | Mobile Money — digital payment via mobile phone (EVC, Zaad, Sahal, Edahab). |
| **KPI** | Key Performance Indicator — a measurable metric for business performance. |
| **ARR** | Annual Recurring Revenue — MRR multiplied by 12. |
| **Churn** | Stores or users that cancel their subscription. |
| **Grace Period** | Extra time after subscription expiry before access is fully locked. |

---

*End of Document*

---

**Prepared by:** KULMIS ERP Product Team  
**Review Status:** Pending Engineering Review  
**Next Review Date:** 2026-06-15
