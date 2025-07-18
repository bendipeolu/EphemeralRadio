package models

type TrackSubmission struct {
    UserID    string  `json:"user_id"`
    TrackID   string  `json:"track_id"`
    Latitude  float64 `json:"latitude"`
    Longitude float64 `json:"longitude"`
}
