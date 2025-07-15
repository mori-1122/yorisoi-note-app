window.onload = function () {
  // フィルター開閉処理
  const filterToggle = document.getElementById("filterToggle");
  const filterCollapse = document.getElementById("filterCollapse");

  if (filterToggle && filterCollapse) {
    filterToggle.onclick = function (e) {
      e.preventDefault();

      const isHidden =
        filterCollapse.style.display === "none" || filterCollapse.style.display === "";
      filterCollapse.style.display = isHidden ? "block" : "none";

      const icon = filterToggle.querySelector("i");
      if (icon) {
        icon.className = isHidden
          ? "bi bi-chevron-double-up"
          : "bi bi-chevron-double-down";
      }
    };
  }

  // サイドメニュー開閉処理
  const menuToggle = document.getElementById("menuToggle");
  const sidebar = document.getElementById("sidebarMenu");

  if (menuToggle && sidebar) {
    menuToggle.addEventListener("click", function (e) {
      e.preventDefault();
      document.body.classList.toggle("open");
      console.log("動いた");
    });
  }
};
