package main

import (
    "log"
    "net/http"

    "ephemeral-radio/handlers"
    "ephemeral-radio/db"
)

func main() {
    db.Init()
    http.HandleFunc("/api/track", handlers.HandleTrack)
    http.HandleFunc("/api/nearby", handlers.HandleNearbyTracks)
    log.Println("Server started on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}