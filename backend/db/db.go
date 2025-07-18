package db

import (
    "database/sql"
    _ "github.com/lib/pq"
    "log"
    "ephemeral-radio/models"
)

var DB *sql.DB

func Init() {
    var err error
	DB, err = sql.Open("postgres", "postgres://postgres:postgres@localhost:5432/radio?sslmode=disable")
    if err != nil {
        log.Fatal(err)
    }
}

func SaveTrack(track models.TrackSubmission) error {
    _, err := DB.Exec(`
        INSERT INTO track_plays (user_id, track_id, lat, lon, played_at)
        VALUES ($1, $2, $3, $4, NOW())
    `, track.UserID, track.TrackID, track.Latitude, track.Longitude)

    if err != nil {
        log.Println("DB INSERT ERROR:", err)
    }

    return err
}


func GetTracksNearby(lat, lon float64) []models.TrackSubmission {
    rows, _ := DB.Query(`
        SELECT user_id, track_id, lat, lon FROM track_plays
        WHERE played_at > NOW() - INTERVAL '1 day'
        AND earth_distance(ll_to_earth($1, $2), ll_to_earth(lat, lon)) < 10000
    `, lat, lon)
    
    var results []models.TrackSubmission
    for rows.Next() {
        var t models.TrackSubmission
        rows.Scan(&t.UserID, &t.TrackID, &t.Latitude, &t.Longitude)
        results = append(results, t)
    }
    return results
}
