# Squarespace Form Setup Instructions

## Important: Make sure Firebase SDK is loaded first!

Before pasting the form code, you MUST include the Firebase SDK scripts in your Squarespace page header or footer.

### Add these scripts to your page header/footer (Settings > Advanced > Code Injection):

```html
<!-- Firebase SDK -->
<script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-storage.js"></script>
```

## Form Element IDs Required

Make sure your Squarespace form has these exact IDs:
- `mainCategory` - Main category dropdown
- `subCategory` - Subcategory dropdown  
- `businessForm` - The form element itself
- `ultra-bf-status` - Status message element (can be a div)
- `submitBtn` - Submit button

## Troubleshooting

If "nothing is showing up":

1. **Check browser console** (F12 > Console tab) for errors
2. **Verify Firebase SDK is loaded**: Open console and type `typeof firebase` - should return "object"
3. **Check form element IDs**: Make sure all IDs match exactly
4. **Check if code is running**: Add `console.log('Form script loaded');` at the top to verify

## Common Issues

- **"Firebase SDK not loaded"**: Add the Firebase scripts to page header/footer
- **"Form elements not found"**: Check that all form elements have the correct IDs
- **Logo upload timeout**: File might be too large (>5MB), try a smaller file


