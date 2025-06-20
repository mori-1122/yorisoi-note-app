document.addEventListener("DOMContentLoaded", () => {
    const toggleBtn = document.getElementById("menuToggle");
    const sidebar = document.getElementById("sidebarMenu");
  
    console.log("DOMContentLoaded", toggleBtn, sidebar);
  
    if (toggleBtn && sidebar) {
      toggleBtn.addEventListener("click", () => {
        console.log("toggle clicked");
        document.body.classList.toggle("open");
      });
    }
  });
  