# Play Console: App content forms

Answers for **Policy and programs → App content**, based on what the app and backend actually do.
If the code changes (new SDKs, analytics, ads, new data), revisit these.

## Privacy policy
`https://aiden-gonzalez.github.io/hydrate_mobile_flutter/privacy.html`
(GitHub Pages must be enabled: repo Settings → Pages → Deploy from branch `main`, folder `/docs`.)

## App access
**All or some functionality is restricted.** Reviewers need an account. Create a dedicated reviewer account on the
production backend and enter its email and password here, with the note:
> Sign in with the credentials above. The map shows fountains and bathrooms near the device; tap a pin for details.

## Ads
**No**, the app does not contain ads.

## Content rating (IARC questionnaire)
- Category: **Reference, News, or Educational**, or "All Other App Types" (Travel & Local isn't a separate category)
- Violence / sexuality / language / controlled substances / gambling: **No**
- **Users can interact or exchange content: Yes** (users upload photos and place names visible to others)
- Shares user location with other users: **No** (only the locations of places they choose to add, not their own location)
- Expected result: Everyone / PEGI 3 with "Users Interact"

## Target audience and content
- Target age groups: **13–15, 16–17, 18 and over** (not under 13; the terms require 13+)
- Appeals to children: **No**

## News app
**No**

## Data safety

**Does your app collect or share any of the required user data types?** Yes
**Is all of the user data collected by your app encrypted in transit?** Yes (HTTPS)
**Do you provide a way for users to request that their data is deleted?** Yes. In-app (Settings → Delete Account) and via
`https://aiden-gonzalez.github.io/hydrate_mobile_flutter/privacy.html#delete`

| Data type | Collected | Shared | Optional? | Purpose | Notes |
|---|---|---|---|---|---|
| Personal info → **Email address** | Yes | No | Required | Account management | Never shown to other users |
| Personal info → **User IDs** (username) | Yes | No | Required | App functionality, Account management | Username is shown publicly on contributions. "Shared" means sent to third parties, which it isn't |
| Location → **Approximate / Precise location** | **No** | No | n/a | n/a | Only used on-device to center the map. The location of a *place you add* is user content, not the user's location. Google's guidance: data processed only on device isn't "collected" |
| Photos and videos → **Photos** | Yes | No | Optional | App functionality | Photos of places the user chooses to upload |
| App activity → **Other user-generated content** | Yes | No | Optional | App functionality | Ratings and places added |
| App info and performance | No | No | | | No crash reporting / analytics SDKs |
| Device or other IDs | No | No | | | |

Service providers (AWS for photo storage, the email provider for reset codes) act on our behalf, which Play does
not count as "sharing".

**Is data processed ephemerally?** No for the above (it's stored).

## Account deletion
- In-app path: **Profile → Settings (gear) → Delete Account**
- Web link: `https://aiden-gonzalez.github.io/hydrate_mobile_flutter/privacy.html#delete`
- Deleted: account, email, password hash, ratings, photos, reports filed. Kept: places the user added (unlinked from them).

## Permissions declarations
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`: foreground only, to show nearby places. **No background location**, so
  no location permissions declaration form is needed.
- Camera / photos: the image picker uses the system photo picker on recent Android versions, so no broad
  `READ_MEDIA_IMAGES` declaration should be needed. Check the merged manifest in the bundle before uploading.

## Government apps / Financial features / Health / Health Connect
Not applicable: answer **No** / not a government app.
