package handlers

import (
    "encoding/json"
    "net/http"
    "strconv"

    "ephemeral-radio/db"
)

func HandleNearbyTracks(w http.ResponseWriter, r *http.Request) {
    latStr := r.URL.Query().Get("lat")
    lonStr := r.URL.Query().Get("lon")

    lat, err1 := strconv.ParseFloat(latStr, 64)
    lon, err2 := strconv.ParseFloat(lonStr, 64)
    if err1 != nil || err2 != nil {
        http.Error(w, "Invalid coordinates", http.StatusBadRequest)
        return
    }

    tracks := db.GetTracksNearby(lat, lon)
    json.NewEncoder(w).Encode(tracks)
}