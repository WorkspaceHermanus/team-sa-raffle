# Team SA Raffle — Setup Guide

## Step 1: PayFast Account (do this first — takes 1-2 days to approve)
1. Go to payfast.co.za and click "Sign Up"
2. Choose "Individual" account
3. Complete verification (SA ID + bank details)
4. Once approved, go to Settings → Integration → copy your **Merchant ID** and **Merchant Key**
5. Open `index.html`, find all 3 PayFast forms and replace:
   - `YOUR_MERCHANT_ID` → your actual Merchant ID
   - `YOUR_MERCHANT_KEY` → your actual Merchant Key
   - `YOUR-DOMAIN` → your Vercel URL (e.g. `team-sa-raffle.vercel.app`)

## Step 2: Make.com Automation (sends WhatsApp ticket numbers)
1. Sign up free at make.com
2. Create a new scenario
3. Add trigger: **Webhooks → Custom Webhook** — copy the webhook URL
4. Paste that URL into `index.html` where it says `YOUR-WEBHOOK-URL` in all 3 forms
5. Add action: **HTTP → Make a request** to CallMeBot API (see Step 3)
6. Add action: **Google Sheets → Add Row** to log the entry

## Step 3: CallMeBot WhatsApp (auto-sends ticket numbers)
1. On Jeanie's phone — save +34 644 62 11 90 as "CallMeBot"
2. Send this WhatsApp message to that number:
   `I allow callmebot to send me messages`
3. You'll receive an API key back — save it
4. In Make.com, the HTTP call URL will be:
   `https://api.callmebot.com/whatsapp.php?phone=JEANIES_NUMBER&text=MESSAGE&apikey=HER_KEY`

## Step 4: Google Sheet
1. Create a new Google Sheet called "Team SA Raffle Entries"
2. Add these column headers in row 1:
   Name | WhatsApp | Package | Tickets | Amount | Date | Payment Reference
3. Connect it in Make.com as the destination for new entries

## Step 5: Generate QR Code
1. Go to qr.io (free)
2. Paste your Vercel URL
3. Download the QR code image
4. Add to the flyer — people scan it to reach the raffle page

## Step 6: Test end-to-end
1. Make a real R10 test payment (PayFast has a sandbox mode too)
2. Check the WhatsApp arrives on Jeanie's phone
3. Check the Google Sheet row was added
4. Check the thank-you page loads correctly

## Files in this project
- `index.html` — public raffle page (this is what buyers see)
- `thankyou.html` — shown after successful payment
- `raffle_manager.html` — admin dashboard (keep the URL private)
- `SETUP_GUIDE.md` — this file

## Draw day (30 June 2026)
1. Open `raffle_manager.html`
2. Make sure all entries are up to date
3. Click "Draw Winner Now"
4. Screenshot the result
5. Send winner announcement on WhatsApp to all buyers
