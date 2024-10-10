'use client';

import { AuthContextProps, useAuth } from "react-oidc-context";

import AppBar from "@/components/AppBar";
import CreatePipeline from "@/components/CreatePipeline";
import Login from "@/components/Login";

function authenticated(auth: AuthContextProps): boolean {
  switch (auth.activeNavigator) {
  case "signinSilent":
  case "signoutRedirect":
    return false;
  }

  return !auth.isLoading && !auth.error && auth.isAuthenticated;
}

export default function Home() {
  const auth = useAuth();
  const properlyAuthenticated = authenticated(auth);
  return (
    <div>
      <AppBar />
      <main>
        {properlyAuthenticated ? (
          <CreatePipeline />
        ) : (
          <Login />
        )}
      </main>
    </div>
  );
}
