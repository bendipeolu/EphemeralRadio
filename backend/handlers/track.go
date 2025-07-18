package handlers

import (
    "encoding/json"
    "net/http"
    "ephemeral-radio/models"
    "ephemeral-radio/db"
)

func HandleTrack(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }

    var track models.TrackSubmission
    if err := json.NewDecoder(r.Body).Decode(&track); err != nil {
        http.Error(w, "Invalid input", http.StatusBadRequest)
        return
    }

    err := db.SaveTrack(track)
    if err != nil {
        http.Error(w, "DB error", http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusCreated)
}
