import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import {
  approveKyc,
  listKycReviews,
  rejectKyc,
  type KycReview,
  type KycVerifiedCustomer,
} from "../api/kyc";
import { Button } from "../components/Button";
import { EmptyState } from "../components/EmptyState";
import { Input } from "../components/Input";
import { LoadingState } from "../components/LoadingState";
import { PageHeader } from "../components/PageHeader";
import { Panel } from "../components/Panel";
import { StatusBadge } from "../components/StatusBadge";

export function KycPage() {
  const [reviews, setReviews] = useState<KycReview[]>([]);
  const [verified, setVerified] = useState<KycVerifiedCustomer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [rejectingId, setRejectingId] = useState<string | null>(null);
  const [rejectReason, setRejectReason] = useState("");
  const [actingOn, setActingOn] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await listKycReviews();
      setReviews(result.reviews);
      setVerified(result.verified ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load KYC queue");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const handleApprove = async (userId: string) => {
    setActingOn(userId);
    setActionError(null);
    try {
      await approveKyc(userId);
      await load();
    } catch (err) {
      setActionError(err instanceof Error ? err.message : "Approval failed");
    } finally {
      setActingOn(null);
    }
  };

  const handleReject = async (userId: string) => {
    if (rejectReason.trim().length < 5) {
      setActionError("Rejection reason must be at least 5 characters.");
      return;
    }

    setActingOn(userId);
    setActionError(null);
    try {
      await rejectKyc(userId, rejectReason.trim());
      setRejectingId(null);
      setRejectReason("");
      await load();
    } catch (err) {
      setActionError(err instanceof Error ? err.message : "Rejection failed");
    } finally {
      setActingOn(null);
    }
  };

  return (
    <div className="page">
      <PageHeader
        eyebrow="Operations"
        title="KYC"
        subtitle="Customers are verified automatically when their PAN is valid and the name matches. Approve and reject require a step-up token from Settings."
      />

      {loading ? <LoadingState label="Loading KYC queue…" /> : null}
      {error ? <p className="error">{error}</p> : null}
      {actionError ? <p className="error">{actionError}</p> : null}

      {!loading && !error ? (
        <Panel title={`Verified customers (${verified.length})`}>
          {verified.length === 0 ? (
            <EmptyState title="No verified customers yet" description="Customers appear here after PAN verification." />
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Customer</th>
                  <th>Phone</th>
                  <th>Status</th>
                  <th>Verified</th>
                  <th>Checks</th>
                </tr>
              </thead>
              <tbody>
                {verified.map((customer) => (
                  <tr key={customer.user_id}>
                    <td>
                      <Link to={`/users/${customer.user_id}`}>
                        {customer.name ?? "Member"}
                      </Link>
                    </td>
                    <td>{customer.phone}</td>
                    <td>
                      <StatusBadge tone="success">Verified</StatusBadge>
                    </td>
                    <td>
                      {customer.verified_at
                        ? new Date(customer.verified_at).toLocaleString()
                        : "—"}
                    </td>
                    <td>
                      <div className="status-row">
                        <StatusBadge tone={customer.pan_verified ? "success" : "pending"}>
                          PAN
                        </StatusBadge>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Panel>
      ) : null}

      {!loading && reviews.length > 0 ? (
        <Panel title="Pending manual review">
          <table className="data-table">
            <thead>
              <tr>
                <th>Customer</th>
                <th>Phone</th>
                <th>Submitted</th>
                <th>Checks</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {reviews.map((review) => (
                <tr key={review.user_id}>
                  <td>
                    <Link to={`/users/${review.user_id}`}>
                      {review.name ?? "Member"}
                    </Link>
                  </td>
                  <td>{review.phone}</td>
                  <td>
                    {review.submitted_at
                      ? new Date(review.submitted_at).toLocaleString()
                      : "—"}
                  </td>
                  <td>
                    <div className="status-row">
                      <StatusBadge tone={review.aadhaar_verified ? "success" : "pending"}>
                        Aadhaar
                      </StatusBadge>
                      <StatusBadge tone={review.pan_verified ? "success" : "pending"}>
                        PAN
                      </StatusBadge>
                    </div>
                  </td>
                  <td>
                    <div className="table-actions">
                      <Button
                        type="button"
                        loading={actingOn === review.user_id}
                        onClick={() => void handleApprove(review.user_id)}
                      >
                        Approve
                      </Button>
                      <Button
                        type="button"
                        variant="secondary"
                        onClick={() => {
                          setRejectingId(
                            rejectingId === review.user_id ? null : review.user_id,
                          );
                          setRejectReason("");
                        }}
                      >
                        Reject
                      </Button>
                    </div>
                    {rejectingId === review.user_id ? (
                      <div className="inline-form">
                        <Input
                          label="Rejection reason"
                          value={rejectReason}
                          onChange={(event) => setRejectReason(event.target.value)}
                          placeholder="Explain what the customer must fix"
                        />
                        <Button
                          type="button"
                          variant="danger"
                          loading={actingOn === review.user_id}
                          onClick={() => void handleReject(review.user_id)}
                        >
                          Confirm reject
                        </Button>
                      </div>
                    ) : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Panel>
      ) : null}
    </div>
  );
}
