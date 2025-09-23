document.addEventListener("DOMContentLoaded", () => {
  const modalEl = document.getElementById("featureGuideModal");
  if (modalEl) {
    const modal = new bootstrap.Modal(modalEl)
    modal.show();
  }
})
