import { api, loadSession } from "../api";

const API_BASE = import.meta.env.VITE_API_BASE ?? "";

function stepUpHeaders(): HeadersInit {
  return {
    "X-Admin-Step-Up": localStorage.getItem("moozhayil_step_up") ?? "",
  };
}

export interface KycReview {
  user_id: string;
  name: string | null;
  phone: string;
  kyc_status: string;
  submitted_at: string | null;
  aadhaar_verified: boolean;
  pan_verified: boolean;
  selfie_verified: boolean;
  selfie_preview_available: boolean;
}

export interface KycVerifiedCustomer {
  user_id: string;
  name: string | null;
  phone: string;
  kyc_status: string;
  verified_at: string | null;
  pan_verified: boolean;
  aadhaar_verified: boolean;
}

export async function listKycReviews() {
  return api<{ reviews: KycReview[]; verified?: KycVerifiedCustomer[] }>(
    "/v1/admin/kyc/reviews",
  );
}

export async function approveKyc(userId: string) {
  return api<{ success: boolean; kyc_status: string }>(
    `/v1/admin/kyc/${userId}/approve`,
    {
      method: "POST",
      headers: stepUpHeaders(),
    },
  );
}

export async function rejectKyc(userId: string, reason: string) {
  return api<{ success: boolean }>(`/v1/admin/kyc/${userId}/reject`, {
    method: "POST",
    headers: stepUpHeaders(),
    body: JSON.stringify({ reason }),
  });
}

export async function fetchKycSelfieUrl(userId: string): Promise<string | null> {
  const session = loadSession();
  const response = await fetch(`${API_BASE}/v1/admin/kyc/${userId}/selfie`, {
    headers: session?.accessToken
      ? { Authorization: `Bearer ${session.accessToken}` }
      : undefined,
  });

  if (!response.ok) {
    return null;
  }

  const blob = await response.blob();
  return URL.createObjectURL(blob);
}
