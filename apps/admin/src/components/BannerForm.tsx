import { useEffect, useState } from "react";
import {
  BANNER_PLACEMENTS,
  CTA_APP_ROUTES,
  type BannerFormValues,
} from "../config/cms";
import { Input } from "./Input";
import { MediaUploadField } from "./MediaUploadField";

interface BannerFormProps {
  values: BannerFormValues;
  onChange: (values: BannerFormValues) => void;
  onSubmit: () => void;
  onCancel: () => void;
  saving: boolean;
  error: string | null;
  mode: "create" | "edit";
}

export function BannerForm({
  values,
  onChange,
  onSubmit,
  onCancel,
  saving,
  error,
  mode,
}: BannerFormProps) {
  const [previewError, setPreviewError] = useState(false);

  useEffect(() => {
    setPreviewError(false);
  }, [values.image_url]);

  const patch = (partial: Partial<BannerFormValues>) => {
    onChange({ ...values, ...partial });
  };

  return (
    <form
      className="banner-form"
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit();
      }}
    >
      <div className="banner-form__header">
        <h2>{mode === "create" ? "New banner" : "Edit banner"}</h2>
        <p className="muted">
          Upload or paste a public image URL. Hero flyers: portrait 9:16 works
          best on phones. Set a button label and destination so taps open the
          right screen in the app.
        </p>
      </div>

      {error ? (
        <div className="login-card__alert" role="alert">
          {error}
        </div>
      ) : null}

      <Input
        label="Title"
        name="title"
        value={values.title}
        onChange={(event) => patch({ title: event.target.value })}
        required
        disabled={saving}
        placeholder="Festive collection launch"
      />

      <Input
        label="Image URL"
        name="image_url"
        type="url"
        value={values.image_url}
        onChange={(event) => patch({ image_url: event.target.value })}
        required
        disabled={saving}
        placeholder="https://cdn.example.com/banners/hero.jpg"
      />

      <MediaUploadField
        folder="banners"
        disabled={saving}
        onUploaded={(url) => patch({ image_url: url })}
      />

      {values.image_url && !previewError ? (
        <div className="banner-form__preview">
          <img
            src={values.image_url}
            alt="Banner preview"
            onError={() => setPreviewError(true)}
          />
        </div>
      ) : null}

      <div className="banner-form__row">
        <div className="field">
          <label className="field__label" htmlFor="placement">
            Placement
          </label>
          <select
            id="placement"
            className="field__input"
            value={values.placement}
            onChange={(event) => patch({ placement: event.target.value })}
            disabled={saving}
          >
            {BANNER_PLACEMENTS.map((item) => (
              <option key={item.value} value={item.value}>
                {item.label}
              </option>
            ))}
          </select>
          <p className="muted field__hint">
            {
              BANNER_PLACEMENTS.find((p) => p.value === values.placement)?.hint ??
              ""
            }
          </p>
        </div>

        <Input
          label="Sort order"
          name="sort_order"
          type="number"
          min={0}
          value={values.sort_order}
          onChange={(event) => patch({ sort_order: event.target.value })}
          disabled={saving}
        />
      </div>

      <div className="banner-form__row">
        <Input
          label="CTA label"
          name="cta_label"
          value={values.cta_label}
          onChange={(event) => patch({ cta_label: event.target.value })}
          disabled={saving}
          placeholder="Shop now"
        />
        <div className="field">
          <label className="field__label" htmlFor="cta_route">
            Button leads to (in app)
          </label>
          <select
            id="cta_route"
            className="field__input"
            value={
              CTA_APP_ROUTES.some((r) => r.value === values.cta_route)
                ? values.cta_route
                : values.cta_route
                  ? "__custom__"
                  : ""
            }
            onChange={(event) => {
              const next = event.target.value;
              if (next !== "__custom__") {
                patch({ cta_route: next });
              }
            }}
            disabled={saving}
          >
            {CTA_APP_ROUTES.map((route) => (
              <option key={route.value || "default"} value={route.value}>
                {route.label}
              </option>
            ))}
            <option value="__custom__">Custom path…</option>
          </select>
          {values.cta_route &&
          !CTA_APP_ROUTES.some((r) => r.value === values.cta_route) ? (
            <Input
              label="Custom route"
              name="cta_route_custom"
              value={values.cta_route}
              onChange={(event) => patch({ cta_route: event.target.value })}
              disabled={saving}
              placeholder="/shop/collection/uuid"
            />
          ) : null}
          <p className="muted field__hint">
            The app shows the hero button only when CTA label is set. Empty
            destination defaults to Shop. Product: /shop/product/&lt;id&gt;
          </p>
        </div>
      </div>

      <div className="banner-form__row">
        <Input
          label="Valid from"
          name="valid_from"
          type="datetime-local"
          value={values.valid_from}
          onChange={(event) => patch({ valid_from: event.target.value })}
          disabled={saving}
        />
        <Input
          label="Valid to"
          name="valid_to"
          type="datetime-local"
          value={values.valid_to}
          onChange={(event) => patch({ valid_to: event.target.value })}
          disabled={saving}
        />
      </div>

      <label className="banner-form__toggle">
        <input
          type="checkbox"
          checked={values.is_active}
          onChange={(event) => patch({ is_active: event.target.checked })}
          disabled={saving}
        />
        <span>Active (visible in customer app when within validity window)</span>
      </label>

      <div className="banner-form__actions">
        <button type="button" className="btn btn--secondary" onClick={onCancel} disabled={saving}>
          Cancel
        </button>
        <button type="submit" className="btn btn--primary" disabled={saving}>
          {saving ? "Saving…" : mode === "create" ? "Create banner" : "Save changes"}
        </button>
      </div>
    </form>
  );
}
