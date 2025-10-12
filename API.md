# HoyoLab Auto API

Simple REST API for Genshin Impact data.

## Setup

Add this to your `config.json5`:

```json5
api: {
    enabled: true,
    port: 8080,
}
```

## Endpoints

All endpoints return JSON responses.

### Get Notes (All Data)

**GET** `/api/genshin/notes`

Returns complete notes data including stamina, expedition, dailies, weeklies, and realm currency for all accounts.

**Example:**
```bash
curl http://localhost:8080/api/genshin/notes
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "uid": "123456789",
      "nickname": "Traveler",
      "region": "os_usa",
      "stamina": {
        "currentStamina": 120,
        "maxStamina": 200,
        "recoveryTime": 9600
      },
      "expedition": {
        "completed": false,
        "list": [...]
      },
      "dailies": {...},
      "weeklies": {...},
      "realm": {...}
    }
  ]
}
```

### Get Expedition Status

**GET** `/api/genshin/expedition`

Returns expedition status for all accounts with expedition checking enabled.

**Example:**
```bash
curl http://localhost:8080/api/genshin/expedition
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "uid": "123456789",
      "nickname": "Traveler",
      "region": "os_usa",
      "expedition": {
        "completed": false,
        "list": [
          {
            "avatar": "https://...",
            "status": "Ongoing",
            "remaining_time": "12000"
          }
        ]
      }
    }
  ]
}
```

### Get Stamina

**GET** `/api/genshin/stamina`

Returns resin/stamina data for all accounts with stamina checking enabled.

**Example:**
```bash
curl http://localhost:8080/api/genshin/stamina
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "uid": "123456789",
      "nickname": "Traveler",
      "region": "os_usa",
      "stamina": {
        "currentStamina": 120,
        "maxStamina": 200,
        "recoveryTime": 9600
      }
    }
  ]
}
```

## Error Responses

```json
{
  "error": "No accounts found"
}
```

```json
{
  "error": "Error message"
}
```
