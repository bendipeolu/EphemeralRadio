# Ephemeral Radio

A location-based iOS app that lets users share what they're listening to in real time using Spotify.  
Tracks submitted by users expire after 24 hours, creating a constantly updating "ephemeral" local feed.

## Features

- 🔊 Shows songs people nearby are playing on Spotify
- 📍 Uses geolocation to build a local, time-sensitive playlist
- ⏳ Automatically expires song data after 24 hours
- 🔐 Spotify login with OAuth + PKCE
- ☁️ Go backend with PostgreSQL, ready for deployment

## Stack

- Swift (iOS frontend)
- Go (backend API)
- PostgreSQL (data store)
- Docker (local dev)
- Spotify Web API (auth + track data)

