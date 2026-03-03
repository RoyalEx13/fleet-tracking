import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let Hooks = {};

function timeAgo(dateString) {
  if (!dateString) return "ไม่ทราบเวลา";
  const now = new Date();
  const past = new Date(dateString);
  const diffInSeconds = Math.floor((now - past) / 1000);

  if (diffInSeconds < 5) return "เมื่อสักครู่";
  if (diffInSeconds < 60) return `${diffInSeconds} วินาทีที่แล้ว`;

  const diffInMinutes = Math.floor(diffInSeconds / 60);
  if (diffInMinutes < 60) return `${diffInMinutes} นาทีที่แล้ว`;

  const diffInHours = Math.floor(diffInMinutes / 60);
  if (diffInHours < 24) return `${diffInHours} ชั่วโมงที่แล้ว`;

  return past.toLocaleDateString();
}

Hooks.LeafletMap = {
  mounted() {
    this.handleEvent("update_vehicle_positions", ({ locations }) => {
      this.updateMarkers(locations);
    });

    this.map = L.map(this.el).setView([13.7563, 100.5018], 10);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap contributors",
    }).addTo(this.map);

    this.markers = {};

    const rawLocations = this.el.dataset.locations;
    if (rawLocations) {
      try {
        const locations = JSON.parse(rawLocations);
        this.updateMarkers(locations);
      } catch (e) {
        console.error("Error parsing locations JSON:", e);
      }
    }

    this.handleEvent("fly_to_vehicle", (loc) => {
      this.map.flyTo([loc.lat, loc.lng], 16, { animate: true, duration: 1.5 });
    });

    const refreshTimes = () => {
      document.querySelectorAll("[data-timestamp]").forEach((el) => {
        const ts = el.getAttribute("data-timestamp");
        if (ts) el.innerText = timeAgo(ts);
      });
    };

    refreshTimes();
    this.timeTicker = setInterval(refreshTimes, 1000);
  },

  updateMarkers(locations) {
    locations.forEach((loc) => {
      const markerId = loc.vehicle_id || loc.id;
      const popupHTML = `<b>${loc.license_plate || markerId}</b><br>Speed: ${loc.speed} km/h`;

      if (this.markers[markerId]) {
        this.markers[markerId].setLatLng([loc.lat, loc.lng]);
      } else {
        this.markers[markerId] = L.marker([loc.lat, loc.lng])
          .addTo(this.map)
          .bindPopup(popupHTML);
      }
    });
  },

  destroyed() {
    if (this.timeTicker) clearInterval(this.timeTicker);
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

liveSocket.connect();

window.liveSocket = liveSocket;
