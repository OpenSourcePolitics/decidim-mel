((exports) => {
  const $ = exports.$; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};

  $(() => {
    let $mapElements = $("[data-decidim-map]");
    
    $mapElements.on("ready.decidim", (event, map, mapConfig) => {
    
      fetch("/data/mel.json")
      .then(response => response.json())
      .then(geojson =>  {
        const geojsonLayer = L.geoJSON(geojson, {
          style: function () {
            return {
              color: "#ff1515",
              weight: 1,
              fillOpacity: 0.05
            };
          }
        }).addTo(map);
  
        if (mapConfig.markers.length == 0) {
          map.fitBounds(geojsonLayer.getBounds());
        }
      });
    
    });
  });
})(window);