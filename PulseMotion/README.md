# PulseMotion

## Introduction
PulseMotion ist der Backend-Server der Hartslag-App.

## Functionality
### POST Requests:
#### Request Body
```
{
    video: BASE64,
    metadata: {
        length: int,
        frames: int,
        px: int,
    }
}
```

#### Request URL's
1. **/face**

2. **/wrist**
