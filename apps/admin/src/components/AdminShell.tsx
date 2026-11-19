import { useEffect, useState } from "react";
import { Navigate, Outlet } from "react-router-dom";
import { api, clearSession, loadSession } from "../api";
import { BrandMark } from "./BrandMark";
import { LoadingState } from "./LoadingState";
import { Sidebar } from "./Sidebar";

type AuthState = "checking" | "authenticated" | "unauthenticated";

export function AdminShell() {
  const session = loadSession();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [authState, setAuthState] = useState<AuthState>(
    session ? "checking" : "unauthenticated",
  );

  useEffect(() => {
    if (!session) {
      setAuthState("unauthenticated");
      return;
    }

    void api("/v1/admin/auth/me")
      .then(() => setAuthState("authenticated"))
      .catch(() => {
        clearSession();
        setAuthState("unauthenticated");
      });
  }, [session]);

  if (authState === "unauthenticated") {
    return <Navigate to="/login" replace />;
  }

  if (authState === "checking") {
    return (
      <div className="auth-gate">
        <LoadingState label="Verifying session…" />
      </div>
    );
  }

  return (
    <div className={`admin-shell${mobileNavOpen ? " admin-shell--nav-open" : ""}`}>
      <div
        className="sidebar-backdrop"
        aria-hidden={!mobileNavOpen}
        onClick={() => setMobileNavOpen(false)}
      />

      <Sidebar onNavigate={() => setMobileNavOpen(false)} />

      <div className="admin-main">
        <header className="admin-topbar">
          <button
            type="button"
            className="admin-topbar__menu"
            aria-label={mobileNavOpen ? "Close navigation" : "Open navigation"}
            aria-expanded={mobileNavOpen}
            onClick={() => setMobileNavOpen((open) => !open)}
          >
            <span />
            <span />
            <span />
          </button>
          <BrandMark compact className="admin-topbar__brand" />
        </header>

        <main className="admin-content">
          <div className="page-enter">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
