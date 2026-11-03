// Runtime environment configuration for static hosting (Vercel, Netlify, GitHub Pages, or local)
// When deploying to Vercel/Netlify, these can also be injected via build step or left as empty string
// to allow interactive in-app configuration.
window.ENV = window.ENV || {
  VITE_SUPABASE_URL: "",
  VITE_SUPABASE_ANON_KEY: "",
  VITE_ADMIN_PASSCODE: "KavAdom1"
};
