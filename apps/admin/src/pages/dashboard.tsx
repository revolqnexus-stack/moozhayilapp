import { Link } from "react-router-dom";
import { useEffect, useState } from "react";
import { api } from "../api";
import { LoadingState } from "../components/LoadingState";
import { PageHeader } from "../components/PageHeader";
import { Panel } from "../components/Panel";

type DashboardData = {
  users_total?: number;
  kyc_pending_reviews?: number;
  sar_pending_reviews?: number;
  low_stock_products?: number;
  orders_pending?: number;
};

const QUICK_ACTIONS = [
  { to: "/kyc", label: "Review KYC", detail: "Pending identity checks" },
  { to: "/orders", label: "Manage orders", detail: "Fulfillment queue" },
  { to: "/users", label: "Customers", detail: "CRM and scheme support" },
  { to: "/inventory", label: "Inventory", detail: "Stock and reservations" },
  { to: "/cms", label: "Banners", detail: "Home and shop placements" },
  { to: "/products", label: "Products", detail: "Catalogue and publish" },
] as const;

export function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    void api<DashboardData>("/v1/admin/dashboard")
      .then(setData)
      .catch((err: Error) => setError(err.message));
  }, []);

  return (
    <div className="page">
      <PageHeader
        eyebrow="Operations"
        title="Dashboard"
        subtitle="Live counts and shortcuts for showroom operations."
      />

      {error ? <p className="text-error">{error}</p> : null}
      {!data && !error ? <LoadingState label="Loading dashboard…" /> : null}

      {data ? (
        <>
          <div className="grid-2">
            <Panel className="reveal-item">
              <div className="stat">{String(data.users_total ?? 0)}</div>
              <div className="muted">Registered customers</div>
            </Panel>
            <Panel className="reveal-item">
              <div className="stat">{String(data.kyc_pending_reviews ?? 0)}</div>
              <div className="muted">KYC pending</div>
            </Panel>
            <Panel className="reveal-item">
              <div className="stat">{String(data.sar_pending_reviews ?? 0)}</div>
              <div className="muted">SAR pending</div>
            </Panel>
            <Panel className="reveal-item">
              <div className="stat">{String(data.low_stock_products ?? 0)}</div>
              <div className="muted">Low stock SKUs</div>
            </Panel>
          </div>

          <Panel title="Quick actions" className="reveal-item dashboard-actions">
            <div className="dashboard-actions__grid">
              {QUICK_ACTIONS.map((action, i) => (
                <Link
                  key={action.to}
                  to={action.to}
                  className={`dashboard-action-card reveal-item`}
                  style={{ animationDelay: `${0.06 * (i + 1)}s` }}
                >
                  <span className="dashboard-action-card__label">
                    {action.label}
                  </span>
                  <span className="dashboard-action-card__detail muted">
                    {action.detail}
                  </span>
                </Link>
              ))}
            </div>
          </Panel>
        </>
      ) : null}
    </div>
  );
}
