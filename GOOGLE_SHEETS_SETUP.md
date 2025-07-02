# Google Sheets Integration Setup Guide

_This guide walks you through everything needed to send new **DebtTracker** entries to the Google Sheet at
<https://docs.google.com/spreadsheets/d/1m7spAKr-3reWF9_ZmoCJNayyLmUIuskDQlPdHEjTTzQ/>_

---

## 1  Enable the **Google Sheets API**

1. Go to the **Google Cloud Console** → <https://console.cloud.google.com/>  
2. In the **Project selector** (top-left), pick your existing project **or** click **"New Project"**, give it a name (e.g. `DebtTracker-iOS`), then **Create**.  
3. With your project active, open **APIs & Services → Library**.  
4. Search for **"Google Sheets API"**, click it, then press **Enable**.

> **Screenshot** – Google Cloud Library page with the _Enable_ button highlighted
> ![Enable Sheets API](https://developers.google.com/sheets/api/images/enable.png)

---

## 2  Create and **restrict** an API Key

1. Still in **APIs & Services**, choose **Credentials** in the left sidebar.  
2. Click **➕ Create Credentials → API key**. Copy the key that pops up (you can view it later).  
3. In the list of keys, click the one you just made to open its settings.  
4. Under **Key restrictions** choose **Application restrictions → iOS apps** and enter your app's **Bundle Identifier** (e.g. `com.yourcompany.DebtTracker`).  
5. Under **API restrictions** select **Restrict key**, tick only **Google Sheets API**, then **Save**.

> **Diagram** – Key restriction flow
> ```text
> +----------------------+   set bundle id   +----------------------+   restrict to Sheets
> |  Create API Key      | ———————→ |  Application Restrict. | ———————→ |  API Restrict.       |
> +----------------------+              +----------------------+              +--------------------+
> ```

_Why restrict?_ It prevents anyone from abusing the key; only your signed iOS app can use it, and only for Google Sheets.

---

## 3  Add the key to the Xcode project

1. In Xcode, open `DebtTracker/GoogleSheetsConfig.swift`.
2. Replace the placeholder text with **your real key**:

```swift
struct GoogleSheetsConfig {
    static let apiKey = "AIzaSyA...REPLACE_ME"  // 👈 paste here
}
```
3. (Optional) If your first row contains headers, start appending from row 2 by changing the range:

```swift
static let targetRange = "Sheet1!A2"  // append after header row
```

---

## 4  Test the integration

1. **Build & run** the app on a device or simulator.
2. Add a new debt item and tap **Save**.
3. Open your Google Sheet and refresh – you should see a new row within a few seconds.
4. If nothing appears, look at the Xcode console; the app logs HTTP status codes and any errors.

| Status | Meaning | Fix |
|--------|---------|-----|
| 200/201 | Success | — |
| 400 ⚠️ | Bad request | Check spreadsheet ID & range |
| 401/403 🔒 | Unauthorized | Key not enabled/restricted incorrectly |
| 404 ❓ | Wrong URL | Verify spreadsheet ID |

---

### Common Troubleshooting

* **Key restricted too tightly** → Temporarily set Application Restrictions to **None**; once it works, re-enable iOS restriction.  
* **Multiple Sheets in workbook** → Make sure `targetRange` targets the correct tab, e.g. `Expenses!A2`.  
* **Network blocked** → Corporate networks might block `*.googleapis.com`; try mobile data or a different Wi-Fi.  

---

Happy tracking! 📊