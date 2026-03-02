import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let Hooks = {};

Hooks.LeafletMap = {
  mounted() {
    console.log("LeafletMap Hook: Mounted");

    this.map = L.map(this.el).setView([13.7563, 100.5018], 10);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
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

    this.handleEvent("update_vehicle_positions", ({ locations }) => {
      this.updateMarkers(locations);
    });
  },

  updateMarkers(locations) {
    locations.forEach(loc => {
      if (this.markers[loc.id]) {
        this.markers[loc.id].setLatLng([loc.lat, loc.lng]);
      } else {
        this.markers[loc.id] = L.marker([loc.lat, loc.lng])
          .addTo(this.map)
          .bindPopup(`<b>Vehicle ID:</b><br>${loc.id}`);
      }
    });
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks
});

window.addEventListener("phx:page-loading-start", _info => topbar.show(300));
window.addEventListener("phx:page-loading-stop", _info => topbar.hide());

liveSocket.connect();

window.liveSocket = liveSocket;