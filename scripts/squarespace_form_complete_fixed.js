<!-- Ultra Black Friday – Business Intake Form -->
<style>
  #ultra-bf-wrapper {
    font-family: system-ui, sans-serif;
    max-width: 900px;
    margin: 0 auto;
    padding: 1.5rem;
    background: #f5f5f7;
  }
  #ultra-bf-wrapper h1,
  #ultra-bf-wrapper h2 {
    color: #1d1d1e;
  }
  #ultra-bf-wrapper form {
    background: #ffffff;
    padding: 1.5rem;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }
  #ultra-bf-wrapper .field-group {
    margin-bottom: 1rem;
  }
  #ultra-bf-wrapper label {
    display: block;
    font-weight: 600;
    margin-bottom: 0.25rem;
  }
  #ultra-bf-wrapper input[type="text"],
  #ultra-bf-wrapper input[type="email"],
  #ultra-bf-wrapper input[type="tel"],
  #ultra-bf-wrapper input[type="url"],
  #ultra-bf-wrapper input[type="number"],
  #ultra-bf-wrapper textarea,
  #ultra-bf-wrapper select {
    width: 100%;
    padding: 0.5rem;
    border-radius: 6px;
    border: 1px solid #ccc;
    font-size: 0.95rem;
    box-sizing: border-box;
  }
  #ultra-bf-wrapper textarea {
    min-height: 60px;
    resize: vertical;
  }
  #ultra-bf-wrapper .inline-options {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem 1rem;
  }
  #ultra-bf-wrapper .inline-options label {
    font-weight: 400;
  }
  #ultra-bf-wrapper button {
    background: #685bc6;
    color: white;
    border: none;
    padding: 0.75rem 1.5rem;
    border-radius: 999px;
    font-size: 1rem;
    cursor: pointer;
  }
  #ultra-bf-wrapper button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  #ultra-bf-status {
    margin-top: 0.75rem;
    font-size: 0.9rem;
    padding: 0.5rem 0.75rem;
    border-radius: 6px;
    display: none;
  }
  #ultra-bf-status.show {
    display: block;
  }
  #ultra-bf-status.success {
    background: #e6f6ec;
    color: #14643d;
    border: 1px solid #a3d9b5;
  }
  #ultra-bf-status.error {
    background: #fdecea;
    color: #b3261e;
    border: 1px solid #f5b5ae;
  }
  #ultra-bf-status.info {
    background: #e8f0fe;
    color: #174ea6;
    border: 1px solid #aecbfa;
  }
</style>

<div id="ultra-bf-wrapper">
  <h1>Ultra Black Friday – Business Intake</h1>
  <p>Submit your business to be featured in the Ultra Black Friday event.</p>

  <form id="businessForm">
    <!-- 1. Business Identity -->
    <h2>1. Business Identity</h2>

    <div class="field-group">
      <label for="businessName">Business Name *</label>
      <input type="text" id="businessName" required />
    </div>

    <div class="field-group">
      <label for="ownerName">Owner / Representative Name *</label>
      <input type="text" id="ownerName" required />
    </div>

    <div class="field-group">
      <label for="email">Email Address (for communication + reports) *</label>
      <input type="email" id="email" required />
    </div>

    <div class="field-group">
      <label for="phone">Phone Number *</label>
      <input type="tel" id="phone" required />
    </div>

    <div class="field-group">
      <label for="website">Business Website URL</label>
      <input type="url" id="website" placeholder="https://..." />
    </div>

    <div class="field-group">
      <label for="mainCategory">Main Business Category *</label>
      <select id="mainCategory" required>
        <option value="">-- Select Main Category --</option>
        <option value="Health & Wellness">Health & Wellness</option>
        <option value="Professional & Financial Services">Professional & Financial Services</option>
        <option value="Retail & Shopping">Retail & Shopping</option>
        <option value="Food & Beverage">Food & Beverage</option>
        <option value="Creative & Media">Creative & Media</option>
        <option value="Education & Training">Education & Training</option>
        <option value="Home & Trades">Home & Trades</option>
        <option value="Community & Nonprofit">Community & Nonprofit</option>
        <option value="Transportation & Automotive">Transportation & Automotive</option>
        <option value="Beauty & Personal Care">Beauty & Personal Care</option>
      </select>
    </div>

    <div class="field-group">
      <label for="subCategory">Specific Type (Subcategory) *</label>
      <select id="subCategory" required>
        <option value="">-- Select a subcategory after choosing main category --</option>
      </select>
    </div>

    <div class="field-group">
      <label for="shortDescription">Business Description (1–2 sentences for users) *</label>
      <textarea id="shortDescription" maxlength="250" required></textarea>
    </div>

    <!-- 2. Business Branding -->
    <h2>2. Business Branding</h2>

    <div class="field-group">
      <label for="logoFile">Logo Upload (PNG preferred) *</label>
      <input type="file" id="logoFile" accept="image/*" required />
      <small>Will be stored in Firebase Storage under <code>BusinessLogos/</code></small>
    </div>

    <div class="field-group">
      <label>Instagram</label>
      <input type="url" id="instagram" placeholder="https://instagram.com/yourhandle" />
    </div>

    <div class="field-group">
      <label>Facebook</label>
      <input type="url" id="facebook" placeholder="https://facebook.com/yourpage" />
    </div>

    <div class="field-group">
      <label>TikTok</label>
      <input type="url" id="tiktok" placeholder="https://tiktok.com/@yourhandle" />
    </div>

    <div class="field-group">
      <label>LinkedIn</label>
      <input type="url" id="linkedin" placeholder="https://linkedin.com/company/..." />
    </div>

    <div class="field-group">
      <label>Twitter / X</label>
      <input type="url" id="twitter" placeholder="https://x.com/yourhandle" />
    </div>

    <!-- 3. Business Location & Service Area -->
    <h2>3. Business Location & Service Area</h2>

    <div class="field-group">
      <label>Service Type (select all that apply)</label>
      <div class="inline-options">
        <label><input type="checkbox" name="serviceType" value="In-person" /> In-person</label>
        <label><input type="checkbox" name="serviceType" value="Online" /> Online</label>
        <label><input type="checkbox" name="serviceType" value="Hybrid" /> Hybrid</label>
      </div>
    </div>

    <div class="field-group">
      <label for="street">Street Address</label>
      <input type="text" id="street" />
    </div>

    <div class="field-group">
      <label for="city">City</label>
      <input type="text" id="city" />
    </div>

    <div class="field-group">
      <label for="state">State</label>
      <input type="text" id="state" />
    </div>

    <div class="field-group">
      <label for="zip">ZIP Code</label>
      <input type="text" id="zip" />
    </div>

    <div class="field-group">
      <label for="mapLink">Google Map Link (optional)</label>
      <input type="url" id="mapLink" placeholder="https://maps.google.com/..." />
    </div>

    <!-- 4. Deal / Offer Details -->
    <h2>4. Deal / Offer Details (“Black Card”)</h2>

    <div class="field-group">
      <label for="dealTitle">Deal Title *</label>
      <input type="text" id="dealTitle" required />
    </div>

    <div class="field-group">
      <label for="dealDescription">Deal Description *</label>
      <textarea id="dealDescription" required></textarea>
    </div>

    <div class="field-group">
      <label for="dealTerms">Deal Terms &amp; Conditions *</label>
      <textarea id="dealTerms" placeholder="Valid only Mon–Fri, first-time customers, etc." required></textarea>
    </div>

    <div class="field-group">
      <label for="discountType">Discount Type *</label>
      <select id="discountType" required>
        <option value="">-- Select Discount Type --</option>
        <option value="% off">Percentage off</option>
        <option value="$ off">Dollar amount off</option>
        <option value="BOGO">Buy one get one</option>
        <option value="Free consultation">Free consultation</option>
        <option value="Exclusive service">Exclusive service</option>
        <option value="Other">Other</option>
      </select>
    </div>

    <div class="field-group">
      <label for="discountValue">Discount Value (if % or $)</label>
      <input type="text" id="discountValue" placeholder="e.g., 15% or $10" />
    </div>

    <div class="field-group">
      <label for="totalCodes">Total Number of Codes Available *</label>
      <input type="number" id="totalCodes" min="1" required />
    </div>

    <div class="field-group">
      <label for="redemptionInstructions">Redemption Instructions *</label>
      <textarea id="redemptionInstructions" placeholder="What staff should do when they see the code" required></textarea>
    </div>

    <!-- 5. Business Insights -->
    <h2>5. Business Insights</h2>
    <div class="field-group">
      <label>Price Range (for most purchases) *</label>
      <div class="inline-options">
        <label><input type="radio" name="priceRange" value="$" required /> $ (Budget)</label>
        <label><input type="radio" name="priceRange" value="$$" /> $$ (Mid-range)</label>
        <label><input type="radio" name="priceRange" value="$$$" /> $$$ (Premium)</label>
        <label><input type="radio" name="priceRange" value="$$$$" /> $$$$ (High-end)</label>
        <label><input type="radio" name="priceRange" value="$$$$$" /> $$$$$ (Luxury)</label>
      </div>
    </div>

    <!-- 6. Business Operational Details -->
    <h2>6. Business Operational Details</h2>

    <div class="field-group">
      <label for="hours">Hours of Operation</label>
      <textarea id="hours" placeholder="Mon–Fri 10am–6pm, Sat 11am–4pm"></textarea>
    </div>

    <div class="field-group">
      <label for="bookingLink">Booking Link (if applicable)</label>
      <input type="url" id="bookingLink" placeholder="https://..." />
    </div>

    <div class="field-group">
      <label for="menuLink">Service / Product Menu (PDF or Link)</label>
      <input type="url" id="menuLink" placeholder="Link to PDF/menu page" />
    </div>

    <!-- Logo upload progress -->
    <div class="field-group">
      <label>Logo Upload Progress</label>
      <progress id="logoProgress" value="0" max="100" style="width: 100%; display: none;"></progress>
      <small id="logoProgressText" style="display: none; font-size: 0.8rem;"></small>
    </div>

    <button type="submit" id="submitBtn">Submit Business</button>
    <div id="ultra-bf-status"></div>
  </form>
</div>

<!-- Firebase (compat SDK for Squarespace) -->
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-firestore-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-storage-compat.js"></script>

<script>
  // Firebase config
  const firebaseConfig = {
    apiKey: "AIzaSyD1ceXxzhfh0VntZinElLEuETGVJWkHGZc",
    authDomain: "culture-connection-d442f.firebaseapp.com",
    projectId: "culture-connection-d442f",
    storageBucket: "culture-connection-d442f.appspot.com",
    messagingSenderId: "809968040469",
    appId: "1:809968040469:web:8c9dd5ebd06660ca78ec1c"
  };

  if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
  }
  const db = firebase.firestore();
  const storage = firebase.storage();

  const subcategoryOptions = {
    "Health & Wellness": [
      "Therapy & Counseling",
      "Mental Health Services",
      "Physical Therapy / Rehabilitation",
      "Fitness & Personal Training",
      "Nutrition / Meal Planning",
      "Chiropractic / Acupuncture",
      "Spa & Massage Services"
    ],
    "Professional & Financial Services": [
      "Accounting & Tax Preparation",
      "Financial Planning & Investment",
      "Legal Services / Law Firms",
      "Insurance Agencies",
      "Business Consulting",
      "Real Estate Agents / Brokers",
      "IT & Tech Support",
      "Marketing / Branding / PR"
    ],
    "Retail & Shopping": [
      "Clothing & Apparel",
      "Beauty Supply Stores",
      "Jewelry & Accessories",
      "Home Décor & Furniture",
      "Electronics / Tech",
      "Bookstores / Stationery",
      "Gift Shops"
    ],
    "Food & Beverage": [
      "Restaurants & Cafés",
      "Catering Services",
      "Food Trucks",
      "Bakeries / Dessert Shops",
      "Bars & Lounges",
      "Meal Prep Businesses"
    ],
    "Creative & Media": [
      "Photography / Videography",
      "Graphic Design / Branding",
      "Music / Production Studios",
      "Publishing & Writing Services",
      "Event Planning & Decor",
      "Art Galleries / Craft Businesses"
    ],
    "Education & Training": [
      "Tutoring & Test Prep",
      "Childcare / Daycare",
      "Professional Coaching",
      "Trade Schools",
      "Online Courses / E-learning Platforms"
    ],
    "Home & Trades": [
      "Construction / Contracting",
      "Landscaping & Lawn Care",
      "Cleaning Services",
      "Plumbing / Electrical / HVAC",
      "Moving & Storage"
    ],
    "Community & Nonprofit": [
      "Nonprofit Organizations",
      "Churches / Faith-Based Groups",
      "Charities & Mutual Aid",
      "Social Justice / Advocacy",
      "Mentorship Programs"
    ],
    "Transportation & Automotive": [
      "Car Dealerships",
      "Auto Repair & Detailing",
      "Rideshare / Delivery Services",
      "Logistics / Trucking"
    ],
    "Beauty & Personal Care": [
      "Hair Salons & Barbershops",
      "Nail Technicians",
      "Estheticians / Skincare",
      "Makeup Artists",
      "Cosmetic Brands"
    ]
  };

  const mainCategorySelect = document.getElementById("mainCategory");
  const subCategorySelect = document.getElementById("subCategory");
  const form = document.getElementById("businessForm");
  const statusEl = document.getElementById("ultra-bf-status");
  const submitBtn = document.getElementById("submitBtn");
  const logoProgress = document.getElementById("logoProgress");
  const logoProgressText = document.getElementById("logoProgressText");

  function setStatus(type, message) {
    statusEl.className = "show " + (type || "");
    statusEl.id = "ultra-bf-status";
    statusEl.textContent = message;
    console.log("[STATUS]", type, message);
  }

  // Populate subcategories
  mainCategorySelect.addEventListener("change", function () {
    const selected = mainCategorySelect.value;
    subCategorySelect.innerHTML = '<option value="">-- Select Subcategory --</option>';
    if (subcategoryOptions[selected]) {
      subcategoryOptions[selected].forEach(function (opt) {
        const optionEl = document.createElement("option");
        optionEl.value = opt;
        optionEl.textContent = opt;
        subCategorySelect.appendChild(optionEl);
      });
    }
  });

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    setStatus("info", "Starting submission…");
    submitBtn.disabled = true;

    (async function () {
      try {
        // Collect values
        const businessName = document.getElementById("businessName").value.trim();
        const ownerName = document.getElementById("ownerName").value.trim();
        const email = document.getElementById("email").value.trim();
        const phone = document.getElementById("phone").value.trim();
        const website = document.getElementById("website").value.trim();
        const mainCategory = mainCategorySelect.value;
        const subCategory = subCategorySelect.value;
        const shortDescription = document.getElementById("shortDescription").value.trim();

        const logoFileInput = document.getElementById("logoFile");
        const logoFile = logoFileInput.files[0];

        console.log("[LOGO]", logoFile);

        const instagram = document.getElementById("instagram").value.trim();
        const facebook = document.getElementById("facebook").value.trim();
        const tiktok = document.getElementById("tiktok").value.trim();
        const linkedin = document.getElementById("linkedin").value.trim();
        const twitter = document.getElementById("twitter").value.trim();

        const serviceTypes = Array.prototype.slice
          .call(document.querySelectorAll('input[name="serviceType"]:checked'))
          .map(function (cb) { return cb.value; });

        const street = document.getElementById("street").value.trim();
        const city = document.getElementById("city").value.trim();
        const state = document.getElementById("state").value.trim();
        const zip = document.getElementById("zip").value.trim();
        const mapLink = document.getElementById("mapLink").value.trim();

        const dealTitle = document.getElementById("dealTitle").value.trim();
        const dealDescription = document.getElementById("dealDescription").value.trim();
        const dealTerms = document.getElementById("dealTerms").value.trim();
        const discountType = document.getElementById("discountType").value;
        const discountValue = document.getElementById("discountValue").value.trim();
        const totalCodes = parseInt(document.getElementById("totalCodes").value, 10) || 0;
        const redemptionInstructions = document.getElementById("redemptionInstructions").value.trim();

        const priceRangeEl = document.querySelector('input[name="priceRange"]:checked');
        const priceRange = priceRangeEl ? priceRangeEl.value : null;

        const hours = document.getElementById("hours").value.trim();
        const bookingLink = document.getElementById("bookingLink").value.trim();
        const menuLink = document.getElementById("menuLink").value.trim();

        if (!logoFile) {
          throw new Error("Please upload a logo file.");
        }
        if (!mainCategory) {
          throw new Error("Please select a main category.");
        }

        setStatus("info", "Preparing Firestore document…");

        // Firestore path
        const categoryDocRef = db.collection("Ultra Black Friday").doc(mainCategory);
        const businessesColRef = categoryDocRef.collection("businesses");
        const businessDocRef = businessesColRef.doc(); // auto ID
        const businessId = businessDocRef.id;

        console.log("[FIRESTORE] businessId:", businessId);

        // Random code prefix
        const randomCodePrefix =
          businessName.replace(/\s+/g, "") + Math.floor(100 + Math.random() * 900);

        // --- Upload logo with progress + timeout ---
        setStatus("info", "Uploading logo… this may take up to a minute.");
        logoProgress.style.display = "block";
        logoProgress.value = 0;
        logoProgressText.style.display = "inline";
        logoProgressText.textContent =
          "Uploading logo… starting (size: " + logoFile.size + " bytes, type: " + logoFile.type + ")";

        let logoUrl = null;
        let logoStoragePath = null;
        let logoUploadError = null;

        try {
          const storagePath =
            "BusinessLogos/" + businessId + "-" + Date.now() + "-" + logoFile.name;
          logoStoragePath = storagePath;
          const logoRef = storage.ref().child(storagePath);
          
          // Add metadata to help with upload
          const metadata = {
            contentType: logoFile.type || 'image/png',
            customMetadata: {
              uploadedBy: 'Squarespace Form',
              businessId: businessId
            }
          };
          
          const uploadTask = logoRef.put(logoFile, metadata);
          console.log("[UPLOAD] Started to", storagePath, "with metadata", metadata);

          let finishedNormally = false;
          let lastProgressPercent = 0;
          let progressCheckInterval = null;

          const uploadPromise = new Promise(function (resolve, reject) {
            // Monitor progress to detect stuck uploads
            progressCheckInterval = setInterval(function() {
              if (uploadTask.snapshot) {
                const currentProgress = uploadTask.snapshot.bytesTransferred;
                const totalBytes = uploadTask.snapshot.totalBytes;
                const currentPercent = totalBytes > 0 
                  ? Math.round((currentProgress / totalBytes) * 100) 
                  : 0;
                
                // If progress hasn't changed in 5 seconds and we're still at 0%, likely CORS/network issue
                if (currentPercent === 0 && lastProgressPercent === 0 && uploadTask.snapshot.state === 'running') {
                  const timeSinceStart = Date.now() - (window.uploadStartTime || Date.now());
                  if (timeSinceStart > 5000) {
                    console.warn("[UPLOAD] Stuck at 0% for 5+ seconds - likely CORS or network issue");
                  }
                }
                lastProgressPercent = currentPercent;
              }
            }, 1000);
            
            uploadTask.on(
              "state_changed",
              function (snapshot) {
                try {
                  window.uploadStartTime = window.uploadStartTime || Date.now();
                  const progress =
                    snapshot.totalBytes > 0
                      ? Math.round(
                          (snapshot.bytesTransferred / snapshot.totalBytes) * 100
                        )
                      : 0;
                  lastProgressPercent = progress;
                  
                  console.log(
                    "[UPLOAD state_changed]",
                    "state:", snapshot.state,
                    "bytesTransferred:", snapshot.bytesTransferred,
                    "totalBytes:", snapshot.totalBytes,
                    "progress%:", progress
                  );
                  
                  logoProgress.value = progress;
                  logoProgressText.textContent = "Uploading logo… " + progress + "%";
                  setStatus("info", "Uploading logo… " + progress + "%");
                  
                  // Clear progress check interval once we have progress
                  if (progress > 0 && progressCheckInterval) {
                    clearInterval(progressCheckInterval);
                    progressCheckInterval = null;
                  }
                } catch (innerErr) {
                  console.error("[UPLOAD] Progress handler error", innerErr);
                  setStatus(
                    "error",
                    "Unexpected error while tracking upload progress: " + innerErr.message
                  );
                }
              },
              function (error) {
                console.error("[UPLOAD] Error callback", error);
                
                // Clear progress check interval
                if (progressCheckInterval) {
                  clearInterval(progressCheckInterval);
                  progressCheckInterval = null;
                }
                
                // Detect CORS errors
                let errorMessage = error.message || String(error);
                if (error.code === 'storage/unauthorized' || 
                    errorMessage.includes('CORS') || 
                    errorMessage.includes('cors') ||
                    errorMessage.includes('Access-Control')) {
                  errorMessage = "CORS/Network Error: Firebase Storage may need CORS configuration. " + 
                    "Check Firebase Console > Storage > Settings > CORS configuration.";
                }
                
                logoUploadError = error;
                logoProgressText.textContent = "Logo upload failed: " + errorMessage;
                setStatus("error", "Logo upload failed: " + errorMessage);
                reject(error);
              },
              async function () {
                console.log("[UPLOAD] Completed successfully");
                finishedNormally = true;
                
                // Clear progress check interval
                if (progressCheckInterval) {
                  clearInterval(progressCheckInterval);
                  progressCheckInterval = null;
                }
                
                try {
                  logoUrl = await logoRef.getDownloadURL();
                  console.log("[UPLOAD] Download URL", logoUrl);
                  logoProgress.value = 100;
                  logoProgressText.textContent = "Upload complete. 100%";
                  resolve();
                } catch (urlErr) {
                  console.error("[UPLOAD] Error getting download URL", urlErr);
                  logoUploadError = urlErr;
                  setStatus("error", "Logo uploaded but URL fetch failed: " + urlErr.message);
                  reject(urlErr);
                }
              }
            );
          });

          // Timeout after 30 seconds if nothing finishes
          const timeoutPromise = new Promise(function (_, reject) {
            setTimeout(function () {
              if (!finishedNormally) {
                // Clear progress check interval
                if (progressCheckInterval) {
                  clearInterval(progressCheckInterval);
                  progressCheckInterval = null;
                }
                
                console.warn("[UPLOAD] Timeout reached (30s). lastProgressPercent =", lastProgressPercent);
                
                let timeoutMessage = "Logo upload timed out after 30 seconds. ";
                if (lastProgressPercent === 0) {
                  timeoutMessage += "Possible causes: slow internet, blocked request, or Firebase Storage CORS/network issue. " +
                    "Note: Progress remained at 0%. This often means the browser could not start sending data to Firebase (network or permission problem).";
                } else {
                  timeoutMessage += "Upload started but didn't complete. Your internet or Firebase may be slow.";
                }
                
                reject(new Error(timeoutMessage));
              }
            }, 30000); // Increased to 30 seconds
          });

          await Promise.race([uploadPromise, timeoutPromise]);
        } catch (uploadOuterErr) {
          // Clear progress check interval
          if (progressCheckInterval) {
            clearInterval(progressCheckInterval);
            progressCheckInterval = null;
          }
          
          console.error("[UPLOAD] Outer catch", uploadOuterErr);
          if (!logoUploadError) {
            logoUploadError = uploadOuterErr;
            let errorMsg = uploadOuterErr.message || String(uploadOuterErr);
            
            // Provide helpful message for 0% progress timeout
            if (errorMsg.includes("0%") || errorMsg.includes("could not start sending data")) {
              errorMsg += " SOLUTION: Configure CORS in Firebase Console > Storage > Settings. " +
                "See instructions in CORS_CONFIG.md";
            }
            
            logoProgressText.textContent = "Logo upload problem: " + errorMsg;
            setStatus("error", "Logo upload problem: " + errorMsg);
          }
        }

        // Prepare data (even if logo failed, we still save everything)
        const now = firebase.firestore.FieldValue.serverTimestamp();

        const data = {
          businessName,
          ownerName,
          email,
          phone,
          website: website || null,
          mainCategory,
          subCategory,
          shortDescription,
          logoUrl: logoUrl || null,
          logoStoragePath: logoStoragePath || null,
          logoUploadStatus: logoUploadError ? "error" : (logoUrl ? "success" : "unknown"),
          logoUploadMessage: logoUploadError ? logoUploadError.message : null,
          social: {
            instagram: instagram || null,
            facebook: facebook || null,
            tiktok: tiktok || null,
            linkedin: linkedin || null,
            twitter: twitter || null
          },
          serviceTypes,
          address: {
            street: street || null,
            city: city || null,
            state: state || null,
            zip: zip || null,
            mapLink: mapLink || null
          },
          deal: {
            title: dealTitle,
            description: dealDescription,
            terms: dealTerms,
            discountType,
            discountValue: discountValue || null,
            totalCodes,
            redemptionInstructions
          },
          priceRange,
          hours: hours || null,
          bookingLink: bookingLink || null,
          menuLink: menuLink || null,
          businessId,
          randomCodePrefix,
          appVisibility: true,
          codeInventoryCount: totalCodes,
          dateCreated: now,
          lastUpdated: now
        };

        setStatus("info", "Saving your business to Firestore…");
        console.log("[FIRESTORE] Writing document", data);
        await businessDocRef.set(data);
        console.log("[FIRESTORE] Document saved");

        if (logoUploadError) {
          setStatus(
            "success",
            "✅ Business submitted, but there was a logo upload issue: " +
              logoUploadError.message +
              " — we still saved all your info. You can send your logo to us directly."
          );
        } else if (!logoUrl) {
          setStatus(
            "success",
            "✅ Business submitted, but we could not confirm the logo URL. We still saved your info."
          );
        } else {
          setStatus(
            "success",
            "✅ Business and logo submitted successfully! Thank you for joining Ultra Black Friday."
          );
        }

        alert("Business submitted! If there was any logo issue, we captured the error on our side.");

        form.reset();
        subCategorySelect.innerHTML =
          '<option value="">-- Select a subcategory after choosing main category --</option>';
        logoProgress.style.display = "none";
        logoProgressText.style.display = "none";
      } catch (err) {
        console.error("[SUBMISSION] Fatal error", err);
        setStatus("error", "Error during submission: " + err.message);
      } finally {
        submitBtn.disabled = false;
      }
    })();
  });
</script>
