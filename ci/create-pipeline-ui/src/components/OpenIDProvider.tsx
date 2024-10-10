'use client';

import { AuthProvider } from 'react-oidc-context';

// Configure OpenID to connect with gitlab
const OID_CONFIG = {
  authority: process.env.NEXT_PUBLIC_GL_URL,
  client_id: process.env.NEXT_PUBLIC_GL_CLIENT_ID,
  redirect_uri: process.env.NEXT_PUBLIC_GL_REDIRECT_URI,
  scope: 'openid api',
  onSigninCallback: () => {
    // Cleanup url params to avoid infinite redirect.
    window.history.replaceState({}, document.title, window.location.pathname);
  },
};


export default function OpenIDProvider({
  children,
} : Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <AuthProvider {...OID_CONFIG}>
      {children}
    </AuthProvider>
  );
}
